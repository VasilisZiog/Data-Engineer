using './main_part2.bicep'

param dataFactoryName = 'datafactorytest1991vz'//change also in part1
param vaults_SQLerver_name = 'vault11991vz2'//change also in part1
param strgVassilis = 'storagetest1991vz2'//change also in part1
param workspaceName='DLT_pipeline'
param tier='premium'
param enableNoPublicIp=true
param tagValues={}
