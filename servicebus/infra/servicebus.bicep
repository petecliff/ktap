@description('Location for all resources.')
param location string = resourceGroup().location

@description('Prefix for resources')
param namespace string = 'ktap'

@description('Environment to deploy to')
param environment string = 'dev'

@description('ServiceBus SKU')
@allowed(['Basic', 'Standard'])
param serviceBusSKU string = 'Standard'

var serviceBusNamespaceName = '${namespace}-sb-${environment}01'
var serviceBusKeyName = '${namespace}-sb-key-${environment}01'

// https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces?pivots=deployment-language-bicep
resource ktapServiceBusNamespaceName 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: serviceBusSKU
  }
  properties: {}
}

// child resource - nb. "parent" and what happens if you remove it...
// https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics?pivots=deployment-language-bicep
resource songsServiceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2021-11-01' = {
  name: 'songs'
  parent: ktapServiceBusNamespaceName
  properties: {
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S' // Who wants to live forever?
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    enableBatchedOperations: true
    supportOrdering: false
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S' // 
    enablePartitioning: false
    enableExpress: false
    // status: 'Active'
  }
}

resource serviceBusAccessKey 'Microsoft.ServiceBus/namespaces/topics/AuthorizationRules@2021-11-01' = {
  parent: songsServiceBusTopic
  name: serviceBusKeyName
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource allMusicTopicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-11-01' = {
  name: 'all'
  parent: songsServiceBusTopic
  properties: {
    lockDuration: 'PT1M'
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    maxDeliveryCount: 10
    enableBatchedOperations: true
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
  }
}

resource johnnyMusicTopicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-11-01' = {
  name: 'johnny'
  parent: songsServiceBusTopic
  properties: {
    lockDuration: 'PT1M'
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    maxDeliveryCount: 10
    enableBatchedOperations: true
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
  }
}

resource johnnyServiceBusRule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2021-11-01' = {
  name: 'johnnyrules'
  parent: johnnyMusicTopicSubscription
  properties: {
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: 'user.genre != \'jazz\''
      requiresPreprocessing: false
    }
  }
}

resource chuckMusicTopicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-11-01' = {
  name: 'chuck'
  parent: songsServiceBusTopic
  properties: {
    lockDuration: 'PT1M'
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    maxDeliveryCount: 10
    enableBatchedOperations: true
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
  }
}

resource chuckServiceBusAction2 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2021-11-01' = {
  name: 'chuckrules1'
  parent: chuckMusicTopicSubscription
  properties: {
    sqlFilter: {
      sqlExpression: 'user.genre != \'rocknroll\''
      requiresPreprocessing: false
    }
    action: {
      sqlExpression: 'SET user.rating = \'1\''
      requiresPreprocessing: false
    }
  }
}

resource chuckServiceBusAction 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2021-11-01' = {
  name: 'chuckrules2'
  parent: chuckMusicTopicSubscription
  properties: {
    sqlFilter: {
      sqlExpression: 'user.genre = \'rocknroll\''
      requiresPreprocessing: false
    }
    action: {
      sqlExpression: 'SET user.rating = \'5\''
      requiresPreprocessing: false
    }
  }
}







