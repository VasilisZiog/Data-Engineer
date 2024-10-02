using './main_part1.bicep'

param vaults_SQLerver_name = 'vault11991vz2'//change also in part2
param roleDefinitionResourceId = '/subscriptions/fcb68e99-c694-4548-82f9-68e303316b3d/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'
param principalId = '4b353188-4170-4737-b9a7-08c40e18d1ba' //vasilis ziogou profile
param location='eastus'
param userpswd = 'vz1234567890!'
param blobContainerName = 'containertest1991vz'
param strgVassilis = 'storagetest1991vz2'//change also in part2
param dataFactoryName = 'datafactorytest1991vz'//change also in part2
param integrationRuntimeName = 'itegrationRuntime1'

