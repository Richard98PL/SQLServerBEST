Select TOP 10 
u.JobId, u.SubscriberId, u.SubscriberKey, 
EventDate, EmailAddress, jo.VersionId, JourneyName,VersionNumber, 'Global' AS 'OptOutType',
CASE
WHEN u.SubscriberKey LIKE '%003%' THEN 'Customer'
WHEN u.SubscriberKey LIKE '%00Q%' THEN 'Lead'
WHEN u.SubscriberKey LIKE '%@%'   THEN 'WebCollect'
END as 'Type',

CONCAT(CONVERT(varchar, u.SubscriberId),
      CONVERT(varchar, u.JobId),
      CONVERT(varchar, u.BatchId),
      CONVERT(varchar, u.IsUnique),
      REPLACE(CONVERT(varchar, u.EventDate, 21), ' ', '' )) AS Id,
(SELECT COUNT(s.SubscriberId) FROM _Sent as s
INNER JOIN _JourneyActivity ja ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
WHERE JobId = u.JobId) as AllSends

/*,(SELECT COUNT(s.SubscriberId) FROM _Sent as s
INNER JOIN _JourneyActivity ja ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
WHERE s.SubscriberKey LIKE '%003%' AND JobId = u.JobId) as AllSendsCustomer,

(SELECT COUNT(s.SubscriberId) FROM _Sent as s
INNER JOIN _JourneyActivity ja ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
WHERE s.SubscriberKey LIKE '%00Q%' AND JobId = u.JobId) as AllSendsLead,

(SELECT COUNT(s.SubscriberId) FROM _Sent as s
INNER JOIN  _JourneyActivity ja ON TriggererSendDefinitionObjectId = ja.JourneyActivityObjectId
WHERE s.SubscriberKey LIKE '%@%' AND JobId = u.JobId) as AllSendsWebCollect*/

FROM ENT._Unsubscribe u 
LEFT JOIN ENT._Subscribers s
ON CONVERT(VARCHAR(500),s.SubscriberId) = CONVERT(VARCHAR(500),u.SubscriberId)
LEFT JOIN _Job j
ON CONVERT(VARCHAR(500),j.JobId) = CONVERT(VARCHAR(500),u.JobId)
LEFT JOIN _JourneyActivity ja
ON CONVERT(VARCHAR(500),ja.JourneyActivityObjectId) = CONVERT(VARCHAR(500),j.TriggererSendDefinitionObjectId)
LEFT JOIN _Journey jo
ON CONVERT(VARCHAR(500),jo.VersionId) = CONVERT(VARCHAR(500),ja.VersionId)
ORDER BY EventDate DESC
