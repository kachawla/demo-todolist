extension radius
extension radiusCompute
extension radiusSecurity
extension radiusData

param environment string

@secure()
param password string

@description('The full container image reference to build and push. Must be lowercase.')
param image string

resource demoApp 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'demo-todolist'
  properties: {
    environment: environment
  }
}

resource database 'Radius.Data/mySqlDatabases@2025-08-01-preview' = {
  name: 'mysql'
  properties: {
    environment: environment
    application: demoApp.id
    database: 'todos'
    version: '8.0'
    secretName: dbSecret.name
  }
}

resource dbSecret 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'dbsecret'
  properties: {
    environment: environment
    application: demoApp.id
    data: {
      USERNAME: {
        value: 'todo_list_app_user'
      }
      PASSWORD: {
        value: password
      }
    }
  }
}

resource demoImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'demo-image'
  properties: {
    environment: environment
    application: demoApp.id
    image: image
    build: {
      context: '/app/demo'
    }
  }
}

resource demoContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'demo-todolist-frontend'
  properties: {
    environment: environment
    application: demoApp.id
    containers: {
      demo: {
        image: demoImage.properties.image
        ports: {
          web: {
            containerPort: 3000
          }
        }
      }
    }
    connections: {
      mysqldb: {
        source: database.id
      }
      demoContainerImage: {
        source: demoImage.id
      }
    }
  }
}
