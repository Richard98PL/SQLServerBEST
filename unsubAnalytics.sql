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
CASE WHEN JourneyVersionSends = 0 THEN null ELSE '%' END) as 'OptOutToJourneyVersionSendRatio'

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
          CONCAT(u.JourneyName, ' - ', u.VersionNumber)) AS 'JourneyVersionSends'
    
    FROM Unsubscribes u
    WHERE JourneyName <> '' AND VersionId <> '' AND [Type] <> ''
    GROUP BY ROLLUP (
    JourneyName, CONCAT(JourneyName, ' - ', VersionNumber), [Type], OptOutType
    ) 
) as X
WHERE JourneyName <> ''
