# Infrastructure as Code met GitLab - Team 3

Deze repository bevat de Infrastructure as Code (IaC) voor het provisioneren en beheren van cloud resources, het implementeren van applicaties en het uitvoeren van infrastructuurtests. Het volledige proces wordt geautomatiseerd via GitLab CI/CD pipelines.

Ook zal er in deze readme pagina verwezen worden naar 1 andere branch namelijk de environments_test branch.

## Overzicht

Het doel van dit project is om een volledig geautomatiseerde infrastructuur te behouden, waar alle wijzigingen worden gecontroleerd via versiebeheer in deze GitLab-repository. Het proces omvat het provisioneren van cloud resources op AWS, het implementeren van applicatiecode en het uitvoeren van infrastructuurtests. De omgeving kan eenvoudig worden vernietigd en opnieuw worden opgebouwd met behulp van de CI/CD-pipeline.

## Library Management System (LMS) Applicatie

Dit project maakt gebruik van een Library Management System als applicatiecode. Het LMS stelt gebruikers in staat om verschillende bibliotheekgerelateerde taken uit te voeren, zoals het aanmaken van gebruikers, het beheren van boeken en het uitlenen ervan. Hier is een korte uitleg over hoe je het LMS kunt gebruiken:

### Interactie met het LMS

Om te interageren met het Library Management System, volg je deze stappen:

1. **Inloggen:**

   - Gebruik de aangemaakte gebruikersaccounts om in te loggen in het LMS.

2. **Gebruikersbeheer:**

   - Maak nieuwe gebruikers aan of bewerk bestaande gebruikersinformatie.

3. **Boekenbeheer:**

   - Voeg nieuwe boeken toe aan de bibliotheek of bewerk bestaande boekeninformatie. Dit is enkel mogelijk met de admin account.

4. **Uitlenen van Boeken:**
   - Selecteer een boek en leen het uit aan een geregistreerde gebruiker.

### Belangrijk

- Zorg ervoor dat je de infrastructuurcorrecties hebt toegepast voordat je interactie hebt met het LMS. Dit garandeert dat de nodige cloud resources zijn geprovisioneerd en de applicatie correct is ingezet.

- Bij het vernietigen en opnieuw opbouwen van de omgeving blijft de gebruikers- en boekeninformatie behouden.

- Bron: https://github.com/hamzaavvan/library-management-system

## Workflow

1. **GitLab CI/CD Pipeline:**

   - De pipeline wordt automatisch getriggerd bij elke commit naar de hoofdbranch.
   - Het bestaat uit de volgende fasen:
     - **Package:** Tijdens dit proces wordt een docker image gebuild met de applicatiecode in de application folder. Deze wordt daarna gepushed naar de GitLab Image Repository.
     - **Validate:** Validatie van de Terraform omgeving.
     - **Plan:** Planning van de infrastructuurwijzigingen.
     - **Apply:** Toepassen van de geplande wijzigingen.
     - **Destroy:** Volledige vernietiging van de omgeving met één klik.
     - **Tests:** Doorheen de pipeline worden er testen gedaan van de infrastructuur en code.
     - - **Update** Word alleen maar toegepast als de flask applicatie aangepast word. Dan word ECS geupdate met de nieuwe image.

2. **Notificaties:**
   - Voortgangs- en statusmeldingen van de pipeline worden verzonden naar een aangewezen Discord-kanaal.
   - Meldingen bevatten informatie over jobs, geslaagde/ mislukte fasen en redenen voor mislukking.

## Enviroments

Helaas moeten we mededelen dat het niet is gelukt om de pipeline onder te verdelen in een testing en productie environment
De code van tot waar we geraakt zijn staat in de environments_test branch

### Gewenste Pipeline Structuur

Om inzicht te geven in de oorspronkelijk beoogde structuur van de pipeline, was het volgende schema bedacht:

1. **Package**: Deze fase omvat het bouwen en opslaan van de Docker-image van de applicatie en het pushen naar de GitLab-containerregistry.

2. **Validate**: In deze fase wordt de Terraform-configuratie gevalideerd om ervoor te zorgen dat alle instellingen correct zijn en voldoen aan de verwachtingen.

3. **Plan**: Hier wordt een Terraform-plan gegenereerd, waarbij eventuele wijzigingen in de infrastructuur worden vastgesteld voordat ze worden toegepast.

4. **Apply Testing**: In deze stap wordt de Terraform-configuratie toegepast op een testomgeving, gevolgd door het uitvoeren van tests om ervoor te zorgen dat alles correct functioneert.

5. **Test**: Extra tests worden hier uitgevoerd, zoals aangepaste testscripts voor de applicatie.

6. **Security Analysis (SAST)**: De beveiligingsanalyse wordt uitgevoerd op de code om potentiële kwetsbaarheden te identificeren.

7. **Apply Production**: De Terraform-configuratie wordt toegepast op de productieomgeving na het doorstaan van alle tests. Ook zou hier de testing omgeving gedestroyed moeten worden.

8. **Update**: Deze fase omvat het bijwerken van de Docker-image en het toepassen van eventuele configuratiewijzigingen.

9. **Destroy**: Handmatige stap om alle resources te vernietigen wanneer dat nodig is, bijvoorbeeld voor opruimdoeleinden.

## AWS Omgevingsconfiguratie

Een visuele weergave van de AWS-omgevingsconfiguratie is te vinden in het [diagram](iac_challenge_schema.png) dat wordt geleverd in deze repository. De infrastructuur volgt gezonde architectonische principes:

- Afzonderlijke services draaien op afzonderlijke resources (machines/containers/serverless).
- Declaratieve code wordt gebruikt waar mogelijk.
- Security Groups volgen het principe van minste privilege.
- Public en private subnets zijn passend geconfigureerd.

## Kenmerken
- Automatische backups: Dagelijks word er een backup gemaakt van de RDS, deze zal 7 dagen beschikbaar blijven voordat het weer verwijderd word.
- AWS inloggegevens test: Bij het starten van de pipeline worden de gegevens van AWS getest.

## Aan de slag

Om deze infrastructuur te gebruiken:

1. Clone deze repository.
2. Configureer je AWS-inloggegevens in de GitLab variables.
3. Pas de parameters in de IaC-code aan indien nodig.
4. Commit je wijzigingen naar de mainbranch.

## Opmerkingen

- De gegevens in de productieomgeving moeten koste wat kost worden behouden. Dit wordt getest tijdens de evaluatie.
- Geen gevoelige informatie, zoals sleutels, staat hardcoded in de code.
