---
services: DNS
platforms: ruby
author: veronicagg
---

# Manage Azure DNS with Ruby

This sample demonstrates how to manage your Azure DNS using a ruby client.

**On this page**

- [Run this sample](#run)
- [What does example.rb do?](#sample)


<a id="run"></a>
1. If you don't already have it, [install Ruby and the Ruby DevKit](https://www.ruby-lang.org/en/documentation/installation/).

1. If you don't have bundler, install it.

    ```
    gem install bundler
    ```

1. Clone the repository.

    ```
    git clone https://github.com/Azure-Samples/dns-ruby-zones-and-recordsets.git
    ```

1. Install the dependencies using bundle.

    ```
    cd dns-sample
    bundle install
    ```

1. Create an Azure service principal either through
    [Azure CLI](https://azure.microsoft.com/documentation/articles/resource-group-authenticate-service-principal-cli/),
    [PowerShell](https://azure.microsoft.com/documentation/articles/resource-group-authenticate-service-principal/)
    or [the portal](https://azure.microsoft.com/documentation/articles/resource-group-create-service-principal-portal/).

1. Set the following environment variables using the information from the service principle that you created.

    ```
    export AZURE_TENANT_ID={your tenant id}
    export AZURE_CLIENT_ID={your client id}
    export AZURE_CLIENT_SECRET={your client secret}
    export AZURE_SUBSCRIPTION_ID={your subscription id}
    ```

    > [AZURE.NOTE] On Windows, use `set` instead of `export`.

1. Run the sample.

    ```
    bundle exec ruby example.rb
    ```

<a id="sample"></a>
## What does example.rb do?

The sample creates a DNS Management client and creates a DNS zone.
It starts by setting up a ResourceManagementClient object using your subscription and credentials.

```ruby
subscription_id = ENV['AZURE_SUBSCRIPTION_ID'] || '11111111-1111-1111-1111-111111111111' # your Azure Subscription Id
provider = MsRestAzure::ApplicationTokenProvider.new(
    ENV['AZURE_TENANT_ID'],
    ENV['AZURE_CLIENT_ID'],
    ENV['AZURE_CLIENT_SECRET'])
credentials = MsRest::TokenCredentials.new(provider)

resource_client = Azure::ARM::Resources::ResourceManagementClient.new(credentials)
resource_client.subscription_id = web_client.subscription_id = subscription_id
```

The sample then sets up a resource group.

```ruby
resource_group_params = Azure::ARM::Resources::Models::ResourceGroup.new.tap do |rg|
  rg.location = WEST_US
end

resource_group_params.class.class

resource_client.resource_groups.create_or_update(GROUP_NAME, resource_group_params)
```

## More information
Please refer to [Azure SDK for Ruby](https://github.com/Azure/azure-sdk-ruby) for more information.
