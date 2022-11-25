SELECT 
[Journey Name], 
[Version Number], 
[Customer Group],
CONVERT(varchar(500), [Opt-Out Type]) as 'Opt-Out Type',
[Selected - Opt-Outs], 

CASE 
    WHEN [Journey - All Sends] != 0 THEN [Journey - All Sends]
    WHEN [Journey - All Sends] = 0 THEN null
    END AS 'Journey - All Sends',
CONCAT(
    CONVERT(
        varchar(500), 
        ROUND(
                CASE WHEN [Journey - All Sends] = 0 THEN null
                ELSE CAST([Selected - Opt-Outs]*100 AS float)/CAST([Journey - All Sends] AS float)
                END,
                2
            )
        ), 
CASE WHEN [Journey - All Sends] = 0 THEN null ELSE '%' END) AS 'Journey - Opt-Out Ratio',


CASE 
    WHEN [Version - All Sends] != 0 THEN [Version - All Sends]
    WHEN [Version - All Sends] = 0 THEN null
    END AS 'Version - All Sends',
CONCAT(
    CONVERT(
        varchar(500), 
        ROUND(
                CASE WHEN [Version - All Sends] = 0 THEN null
                ELSE CAST([Selected - Opt-Outs]*100 AS float)/CAST([Version - All Sends] AS float)
                END,
                2
            )
        ), 
CASE WHEN [Version - All Sends] = 0 THEN null ELSE '%' END) AS 'Version - Opt-Out Ratio',





CASE 
    WHEN [Version - All Sends To Customer Group] != 0 THEN [Version - All Sends To Customer Group]
    WHEN [Version - All Sends To Customer Group] = 0 THEN null
    END AS 'Version - All Sends To Customer Group',
CONCAT(
    CONVERT(
        varchar(500), 
        ROUND(
                CASE WHEN [Version - All Sends To Customer Group] = 0 THEN null
                ELSE CAST([Selected - Opt-Outs]*100 AS float)/CAST([Version - All Sends To Customer Group] AS float)
                END,
                2
            )
        ), 
CASE WHEN [Version - All Sends To Customer Group] = 0 THEN null ELSE '%' END) AS 'Version - Opt-Out Ratio in Selected Group'








FROM (
    SELECT 
    JourneyName AS 'Journey Name', 
    CONCAT(JourneyName, ' - ', VersionNumber) AS 'Version Number',
    [Type] AS 'Customer Group',
    CONVERT(varchar(500), OptOutType) as 'Opt-Out Type',
    Count(Id) AS 'Selected - Opt-Outs',
    
    (SELECT COUNT(*) FROM _Sent
    INNER JOIN _JourneyActivity ja 
    ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
    INNER JOIN _Journey j
    ON j.VersionId = ja.VersionId
    WHERE j.JourneyName = u.JourneyName) AS 'Journey - All Sends',
    
    (SELECT COUNT(*) FROM _Sent
    INNER JOIN _JourneyActivity ja 
    ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
    INNER JOIN _Journey j
    ON j.VersionId = ja.VersionId
    WHERE CONCAT(j.JourneyName, ' - ', j.VersionNumber) =
          CONCAT(u.JourneyName, ' - ', u.VersionNumber)) AS 'Version - All Sends',
    
    (SELECT COUNT(Distinct SubscriberId) FROM _Sent s
        INNER JOIN _JourneyActivity ja 
        ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
        INNER JOIN _Journey j
        ON j.VersionId = ja.VersionId
        WHERE CONCAT(j.JourneyName, ' - ', j.VersionNumber) =
              CONCAT(u.JourneyName, ' - ', u.VersionNumber)
       AND s.SubscriberKey LIKE
       CASE
        WHEN u.[Type] = 'Newsletter Form' THEN '%@%'
        WHEN u.[Type] = 'Cold Lead Dropout' THEN '%00Q%'
        WHEN u.[Type] = 'VIP Customer' THEN '%003%'
     END) AS 'Version - All Sends To Customer Group'
    
    FROM Unsubscribes u
    WHERE JourneyName <> '' AND VersionId <> '' AND [Type] <> ''
    GROUP BY ROLLUP (
    JourneyName, CONCAT(JourneyName, ' - ', VersionNumber), [Type], OptOutType
    ) 
) AS X
WHERE [Journey Name] <> ''
