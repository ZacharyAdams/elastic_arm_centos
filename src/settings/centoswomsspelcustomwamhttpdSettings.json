{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "esVersion": {
      "value": "7.11.2"
    },
    "esClusterName": {
      "value": "elastictest"
    },
    "azureCloudPlugin": {
      "value": "No"
    },
    "azureCloudStorageAccountName": {
      "value": ""
    },
    "azureCloudStorageAccountResourceGroup": {
      "value": ""
    },
    "xpackPlugins": {
      "value": "Yes"
    },
    "esAdditionalPlugins": {
      "value": "analysis-phonetic"
    },
    "esAdditionalYaml": {
      "value": ""
    },
    "esHttpCertBlob": {
      "value": ""
    },
    "esHttpCertPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "esHttpCaCertBlob": {
      "value": ""
    },
    "esHttpCaCertPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "esTransportCaCertBlob": {
      "value": ""
    },
    "esTransportCaCertPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "esTransportCertPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "samlMetadataUri": {
      "value": ""
    },
    "samlServiceProviderUri": {
      "value": ""
    },
    "esHeapSize": {
      "value": 0
    },
    "loadBalancerType": {
      "value": "external"
    },
    "vNetNewOrExisting": {
      "value": "existing"
    },
    "vNetName": {
      "value": "es7d-vnet-dev"
    },
    "vNetClusterSubnetName": {
      "value": "es-subnet"
    },
    "vNetLoadBalancerIp": {
      "value": "10.74.0.4"
    },
    "vNetExistingResourceGroup": {
      "value": "VDMRes-VADevES7xd"
    },
    "vNetNewAddressPrefix": {
      "value": "10.74.0.0/24"
    },
    "vNetNewClusterSubnetAddressPrefix": {
      "value": "10.74.0.0/25"
    },
    "vNetAppGatewaySubnetName": {
      "value": "es-gateway-subnet"
    },
    "vNetNewAppGatewaySubnetAddressPrefix": {
      "value": "10.0.0.128/28"
    },
    "kibana": {
      "value": "Yes"
    },
    "vmSizeKibana": {
      "value": "Standard_DS1_v2"
    },
    "vmKibanaAcceleratedNetworking": {
      "value": "Default"
    },
    "kibanaKeyBlob": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "kibanaCertBlob": {
      "value": ""
    },
    "kibanaKeyPassphrase": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "kibanaAdditionalYaml": {
      "value": ""
    },
    "logstash": {
      "value": "No"
    },
    "vmLogstashAcceleratedNetworking": {
      "value": "Default"
    },
    "logstashHeapSize": {
      "value": 0
    },
    "logstashKeystorePassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "logstashAdditionalYaml": {
      "value": ""
    },
    "jumpbox": {
      "value": "No"
    },
    "vmSizeDataNodes": {
      "value": "Standard_DS1_v2"
    },
    "vmDataNodeAcceleratedNetworking": {
      "value": "Default"
    },
    "vmDataDiskCount": {
      "value": 1
    },
    "vmDataDiskSize": {
      "value": "1TiB"
    },
    "vmDataNodeCount": {
      "value": 3
    },
    "storageAccountType": {
      "value": "Default"
    },
    "dataNodesAreMasterEligible": {
      "value": "Yes"
    },
    "vmHostNamePrefix": {
      "value": "es7d"
    },
    "vmMasterNodeAcceleratedNetworking": {
      "value": "Default"
    },
    "vmClientNodeCount": {
      "value": 1
    },
    "vmSizeClientNodes": {
      "value": "Standard_D1_v2"
    },
    "vmClientNodeAcceleratedNetworking": {
      "value": "Default"
    },
    "adminUsername": {
      "value": "localadmin"
    },
    "authenticationType": {
      "value": "password"
    },
    "adminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityBootstrapPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityApmPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityAdminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityReadPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityKibanaPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityLogstashPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityRemoteMonitoringPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "securityBeatsPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "appGatewayTier": {
      "value": "Standard"
    },
    "appGatewaySku": {
      "value": "Small"
    },
    "appGatewayCount": {
      "value": 1
    },
    "appGatewayCertBlob": {
      "value": ""
    },
    "appGatewayCertPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "deploypass"
      }
    },
    "appGatewayEsHttpCertBlob": {
      "value": ""
    },
    "appGatewayWafStatus": {
      "value": "Disabled"
    },
    "appGatewayWafMode": {
      "value": "Detection"
    },
    "location": {
      "value": "usgovvirginia"
    },
    "ExistingImageResourceGroupName": {
      "value": "VDMRes-VADevSPEL",
      "metadata": {
        "description": "Resource Group containing the existing image to use for VMs"
      }
    },
    "ExistingImageName": {
      "value": "spel-minimal-centos-7-azure-image-2021.03.rc1",
      "metadata": {
        "description": "Name of the Image to use for VMs"
      }
    },
    "OMSWorkSpaceId": {
      "value": "2f0ef614-6520-40c5-911c-a18effa5aa95",
      "metadata": {
        "description": "OMS Workspace ID"
      }
    },
    "OMSWorkSpaceKey": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "erikomskey"
      }
    },
    "installTrendYN": {
      "value": "no",
      "metadata": {
        "description": "Should this install Trend agent to the VMs"
      }
    },
    "TrendRPMURL": {
      "value": "https://10.33.0.20:4119/software/agent/RedHat_EL7/x86_64/",
      "metadata": {
        "description": "URL from which to download the EL7 Trend Micro Deep Security agent RPM"
      }
    },
    "TrendMgrHostname": {
      "value": "10.33.0.20",
      "metadata": {
        "description": "Hostname or IP of the Trend Micro Deep Security Manager server to link to (e.g. trend.example.com)."
      }
    },
    "TrendPolicyID": {
      "value": "3",
      "metadata": {
        "description": "Policy ID with which to associate the new Trend Micro Deep Security agent"
      }
    },
    "installNessusYN": {
      "value": "no",
      "metadata": {
        "description": "Should this install Nessus agent to the VMs"
      }
    },
    "NessusRPMURL": {
      "value": "https://vsmstoreprod2general01.file.core.usgovcloudapi.net/ddtcsecurity/Binaries/latest/rhel-nessus-agent.rpm",
      "metadata": {
        "description": "Insecure URL from which to download the EL7 Nessus agent RPM."
      }
    },
    "NessusRPMURLSharedAccessSignature": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "stagenessussas"
      }
    },
    "NessusMgrHostname": {
      "value": "10.33.0.6",
      "metadata": {
        "description": "Hostname or IP of the Nessus Manager server to link to (e.g. nessus.example.com)."
      }
    },
    "NessusMgrKey": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "stagenessuskey"
      }
    },
    "NessusGroups": {
      "value": "RHEL7",
      "metadata": {
        "description": "Existing Agent Group(s) that you want your Agent to be a member of"
      }
    },
    "WAMConfURL": {
      "value": "https://erikdiagstorageacct.file.core.usgovcloudapi.net/certs/config.yaml",
      "metadata": {
        "description": "Custom conf.yaml file to use with Watchmaker"
      }
    },
    "WAMConfURLSharedAccessSignature": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "stagecapubcertsas"
      }
    },
    "WAMCustomSaltURL": {
      "value": "https://erikdiagstorageacct.file.core.usgovcloudapi.net/certs/salt-content-20210316.zip",
      "metadata": {
        "description": "URL to Custom salt-content.zip"
      }
    },
    "WAMCustomSaltURLSharedAccessSignature": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "stagecapubcertsas"
      }
    },
    "DomainDNSServerIP1": {
      "value": "10.33.0.4",
      "metadata": {
        "description": "IP address of domain DNS server to be used for domain join"
      }
    },
    "DomainDNSServerIP2": {
      "value": "10.33.0.5",
      "metadata": {
        "description": "IP address of domain DNS server to be used for domain join"
      }
    },
    "DomainDNSdomainsuffix": {
      "value": "dstate.stage",
      "metadata": {
        "description": "DNS suffix of domain to be used for domain join"
      }
    },
    "pubwatchmakerpinnedversion": {
      "value": "0.21.8",
      "metadata": {
        "description": "Version of Watchmaker to which to pin install"
      }
    },
    "KibanaLDAPSCertURL": {
      "value": "https://erikdiagstorageacct.file.core.usgovcloudapi.net/certs/vsmvms-caroot01-pub.cer",
      "metadata": {
        "description": "URL to LDAPS Public cert to be used on Kibana node"
      }
    },
    "KibanaLDAPSCertURLSharedAccessSignature": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "stagecapubcertsas"
      }
    },
    "KibanaEnvContentURL": {
      "value": "https://erikdiagstorageacct.file.core.usgovcloudapi.net/certs/content.zip",
      "metadata": {
        "description": "URL to the Environment Content zip file to be used on Kibana node"
      }
    },
    "KibanaEnvContentURLSharedAccessSignature": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "stagecapubcertsas"
      }
    },
    "KibanaLDAPGroupDN": {
      "value": "cn=dStateKibanaAccess,ou=dState Groups,dc=dstate,dc=stage",
      "metadata": {
        "description": "LDAP DN of the group of users to be granted access to Kibana"
      }
    },
    "NameSynonymsURL": {
      "value": "https://erikdiagstorageacct.file.core.usgovcloudapi.net/certs/name_synonyms.txt",
      "metadata": {
        "description": "URL to the Environment Content zip file to be used on Kibana node"
      }
    },
    "NameSynonymsURLSharedAccessSignature": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/06f70219-4460-452c-8719-7a92c733d7d4/resourceGroups/ErikResourceGroup/providers/Microsoft.KeyVault/vaults/templatetesting"
        },
        "secretName": "stagecapubcertsas"
      }
    }
  }
}
