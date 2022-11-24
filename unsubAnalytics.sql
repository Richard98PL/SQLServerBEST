SELECT JourneyName, 
VersionNumber, 
[Type], 
OptOutType, 
OptOutQuantity, 
CASE 
    WHEN JourneySends != 0 THEN JourneySends
    WHEN JourneySends = 0 THEN null
    END AS 'JourneySends',
CONCAT(
    CONVERT(
        varchar(500), 
        ROUND(
                CASE WHEN JourneySends = 0 THEN null
                ELSE CAST(OptOutQuantity*100 as float)/CAST(JourneySends as float)
                END,
                2
            )
        ), 
CASE WHEN JourneySends = 0 THEN null ELSE '%' END) as 'OptOutToJourneySendRatio',

CASE 
    WHEN JourneyVersionSends != 0 THEN JourneyVersionSends
    WHEN JourneyVersionSends = 0 THEN null
    END AS 'JourneyVersionSends',
CONCAT(
    CONVERT(
        varchar(500), 
        ROUND(
                CASE WHEN JourneyVersionSends = 0 THEN null
                ELSE CAST(OptOutQuantity*100 as float)/CAST(JourneyVersionSends as float)
                END,
                2
            )
        ), 
CASE WHEN JourneyVersionSends = 0 THEN null ELSE '%' END) as 'OptOutToJourneyVersionSendRatio',





CASE 
    WHEN AllVersionReceiversOfType != 0 THEN AllVersionReceiversOfType
    WHEN AllVersionReceiversOfType = 0 THEN null
    END AS 'AllVersionReceiversOfType',
CONCAT(
    CONVERT(
        varchar(500), 
        ROUND(
                CASE WHEN AllVersionReceiversOfType = 0 THEN null
                ELSE CAST(OptOutQuantity*100 as float)/CAST(AllVersionReceiversOfType as float)
                END,
                2
            )
        ), 
CASE WHEN AllVersionReceiversOfType = 0 THEN null ELSE '%' END) as 'OptOutToJourneyVersionSendPerTypeRatio'








FROM (
    SELECT 
    JourneyName, CONCAT(JourneyName, ' - ', VersionNumber) AS 'VersionNumber', [Type], OptOutType, 
    Count(Id) AS 'OptOutQuantity',
    
    (SELECT COUNT(*) FROM _Sent
    INNER JOIN _JourneyActivity ja 
    ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
    INNER JOIN _Journey j
    ON j.VersionId = ja.VersionId
    WHERE j.JourneyName = u.JourneyName) AS 'JourneySends',
    
    (SELECT COUNT(*) FROM _Sent
    INNER JOIN _JourneyActivity ja 
    ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
    INNER JOIN _Journey j
    ON j.VersionId = ja.VersionId
    WHERE CONCAT(j.JourneyName, ' - ', j.VersionNumber) =
          CONCAT(u.JourneyName, ' - ', u.VersionNumber)) AS 'JourneyVersionSends',
    
    (SELECT COUNT(Distinct SubscriberId) FROM _Sent s
        INNER JOIN _JourneyActivity ja 
        ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
        INNER JOIN _Journey j
        ON j.VersionId = ja.VersionId
        WHERE CONCAT(j.JourneyName, ' - ', j.VersionNumber) =
              CONCAT(u.JourneyName, ' - ', u.VersionNumber)
       AND s.SubscriberKey LIKE
       CASE
        WHEN u.[Type] = 'WebCollect' THEN '%@%'
        WHEN u.[Type] = 'Lead' THEN '%00Q%'
        WHEN u.[Type] = 'Contact' THEN '%003%'
     END) AS 'AllVersionReceiversOfType'
    
    FROM Unsubscribes u
    WHERE JourneyName <> '' AND VersionId <> '' AND [Type] <> ''
    GROUP BY ROLLUP (
    JourneyName, CONCAT(JourneyName, ' - ', VersionNumber), [Type], OptOutType
    ) 
) as X
WHERE JourneyName <> ''
