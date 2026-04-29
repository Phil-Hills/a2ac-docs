// A2AC Core Substrate — Azure Marketplace Deployment
// Deploys into customer's Azure tenant as a Managed Application.
// Zero external dependencies. Data never leaves their firewall.

@description('Location for all resources')
param location string = resourceGroup().location

@description('A2AC subscription plan: community, pro, or enterprise')
@allowed(['community', 'pro', 'enterprise'])
param a2acPlan string = 'community'

@description('Container image for A2AC Swarm Node')
param containerImage string = 'a2acllc.azurecr.io/a2ac-swarm-node:latest'

// ──────────────────────────────────────────────
// Log Analytics Workspace (required by Container Apps)
// ──────────────────────────────────────────────
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'a2ac-logs'
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 90
  }
}

// ──────────────────────────────────────────────
// Container Apps Environment
// ──────────────────────────────────────────────
resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'a2ac-environment'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// ──────────────────────────────────────────────
// A2AC Swarm Node (Container App)
// ──────────────────────────────────────────────
resource a2acSwarm 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'a2ac-swarm-node'
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          name: 'a2ac-swarm'
          image: containerImage
          resources: {
            cpu: json('1.0')
            memory: '2Gi'
          }
          env: [
            { name: 'A2AC_PLAN', value: a2acPlan }
            { name: 'A2AC_CLOUD', value: 'azure' }
            { name: 'A2AC_ENTITLEMENT_URL', value: 'https://api.a2ac.ai/entitlement/check' }
            { name: 'AZURE_COSMOS_ENDPOINT', value: cosmosAccount.properties.documentEndpoint }
            { name: 'AZURE_COSMOS_KEY', value: cosmosAccount.listKeys().primaryMasterKey }
            { name: 'AZURE_SERVICEBUS_CONNECTION', value: serviceBusNamespace.listKeys(serviceBusAuthRule.id, '2021-11-01').primaryConnectionString }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
        rules: [
          {
            name: 'http-scaling'
            http: { metadata: { concurrentRequests: '50' } }
          }
        ]
      }
    }
  }
}

// ──────────────────────────────────────────────
// Cosmos DB (Semantic Memory — replaces ChromaDB + Vertex AI)
// ──────────────────────────────────────────────
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: 'a2ac-memory'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      { locationName: location, failoverPriority: 0 }
    ]
    capabilities: [
      { name: 'EnableServerless' }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosAccount
  name: 'a2ac-brain'
  properties: {
    resource: { id: 'a2ac-brain' }
  }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: cosmosDb
  name: 'memories'
  properties: {
    resource: {
      id: 'memories'
      partitionKey: { paths: ['/agent_id'], kind: 'Hash' }
      indexingPolicy: {
        includedPaths: [{ path: '/*' }]
      }
    }
  }
}

// ──────────────────────────────────────────────
// Service Bus (Agent-to-Agent Routing — replaces Pub/Sub)
// ──────────────────────────────────────────────
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: 'a2ac-routing'
  location: location
  sku: { name: 'Basic', tier: 'Basic' }
}

resource serviceBusAuthRule 'Microsoft.ServiceBus/namespaces/authorizationRules@2021-11-01' existing = {
  parent: serviceBusNamespace
  name: 'RootManageSharedAccessKey'
}

resource workflowQueue 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  parent: serviceBusNamespace
  name: 'a2ac-workflow-events'
  properties: {
    maxDeliveryCount: 10
    defaultMessageTimeToLive: 'P14D'
  }
}

// ──────────────────────────────────────────────
// Outputs
// ──────────────────────────────────────────────
output serviceUrl string = 'https://${a2acSwarm.properties.configuration.ingress.fqdn}'
output agentCardUrl string = 'https://${a2acSwarm.properties.configuration.ingress.fqdn}/.well-known/agent.json'
output healthCheckUrl string = 'https://${a2acSwarm.properties.configuration.ingress.fqdn}/health'
output cosmosEndpoint string = cosmosAccount.properties.documentEndpoint
