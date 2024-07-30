@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Topic')
param serviceBusTopicName string

@description('Name of the Subscription')
param serviceBusSubscriptionName string

@description('Name of the Rule')
param serviceBusRuleName string

@description('Location for all resources.')
param location string = resourceGroup().location

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2018-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

resource serviceBusNamespaceName_serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' = {
  parent: serviceBusNamespace
  name: '${serviceBusTopicName}'
  properties: {
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: false
    supportOrdering: 'false'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: 'false'
    enableExpress: 'false'
  }
}

resource serviceBusNamespaceName_serviceBusTopicName_serviceBusSubscription 'Microsoft.ServiceBus/namespaces/topics/Subscriptions@2017-04-01' = {
  parent: serviceBusNamespaceName_serviceBusTopic
  name: serviceBusSubscriptionName
  properties: {
    lockDuration: 'PT1M'
    requiresSession: 'false'
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: 'false'
    maxDeliveryCount: '10'
    enableBatchedOperations: 'false'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
  }
}

resource serviceBusNamespaceName_serviceBusTopicName_serviceBusSubscriptionName_serviceBusRule 'Microsoft.ServiceBus/namespaces/topics/Subscriptions/Rules@2017-04-01' = {
  parent: serviceBusNamespaceName_serviceBusTopicName_serviceBusSubscription
  name: serviceBusRuleName
  properties: {
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: 'FilterTag = \'true\''
      requiresPreprocessing: 'false'
    }
  }
}
