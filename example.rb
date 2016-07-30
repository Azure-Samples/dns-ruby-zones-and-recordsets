#!/usr/bin/env ruby

require 'azure_mgmt_resources'
require 'azure_mgmt_dns'
require 'dotenv'

Dotenv.load(File.join(__dir__, './.env'))

GROUP_NAME = 'azure-sample-group'
WEST_US = 'westus'
ZONE_NAME = "rubysdk_zone.com"

# This script expects that the following environment vars are set:
#
# AZURE_TENANT_ID: with your Azure Active Directory tenant id or domain
# AZURE_CLIENT_ID: with your Azure Active Directory Application Client ID
# AZURE_CLIENT_SECRET: with your Azure Active Directory Application Secret
# AZURE_SUBSCRIPTION_ID: with your Azure Subscription Id
#
def run_example
  #
  # Create the Resource Manager Client with an Application (service principal) token provider
  #
  subscription_id = ENV['AZURE_SUBSCRIPTION_ID'] || '11111111-1111-1111-1111-111111111111' # your Azure Subscription Id
  provider = MsRestAzure::ApplicationTokenProvider.new(
      ENV['AZURE_TENANT_ID'],
      ENV['AZURE_CLIENT_ID'],
      ENV['AZURE_CLIENT_SECRET'])
  credentials = MsRest::TokenCredentials.new(provider)
  dns_client = Azure::ARM::Dns::DnsManagementClient.new(credentials)
  dns_client.long_running_operation_retry_timeout = ENV.fetch('RETRY_TIMEOUT', 30).to_i
  resource_client = Azure::ARM::Resources::ResourceManagementClient.new(credentials)
  resource_client.subscription_id = dns_client.subscription_id = subscription_id
  resource_client.long_running_operation_retry_timeout = ENV.fetch('RETRY_TIMEOUT', 30).to_i

  #
  # Create a resource group
  #
  resource_group_params = Azure::ARM::Resources::Models::ResourceGroup.new.tap do |rg|
    rg.location = WEST_US
  end

  resource_group_params.class.class

  puts 'Create Resource Group'
  print_item resource_client.resource_groups.create_or_update(GROUP_NAME, resource_group_params)

  #
  # Create a DNS zone
  #
   puts 'Create a DNS zone'
  zone = Azure::ARM::Dns::Models::Zone.new()
  zone.location = "global"
  zone.tags = {
      :dept => "shopping",
      :env => "production"
  }

  dns_zone_updated = dns_client.zones.create_or_update(GROUP_NAME, ZONE_NAME, zone)
  print_item dns_zone_updated

  #
  # Create a DNS record
  #
  puts 'Create a DNS record'
  record = Azure::ARM::Dns::Models::RecordSet.new.tap do |r|
    arecord1 = Azure::ARM::Dns::Models::ARecord.new.tap do |a|
      a.ipv4address = "1.2.3.4"
    end
    arecord2 = Azure::ARM::Dns::Models::ARecord.new.tap do |a|
      a.ipv4address = "1.2.3.5"
    end
    r.arecords = [arecord1 , arecord2]
  end
  record_params = Azure::ARM::Dns::Models::RecordSetUpdateParameters.new.tap do |r|
    r.record_set = record
  end

  dns_client.record_sets.create_or_update(GROUP_NAME, ZONE_NAME, "www", Azure::ARM::Dns::Models::RecordType::A, record_params)

  puts "List dns zones for resource group:"
  puts "\t #{dns_client.zones.list_in_resource_group(GROUP_NAME)}"

  puts "List dns record sets for resource group:"
  puts "\t #{dns_client.record_sets.list_all_in_resource_group(GROUP_NAME, ZONE_NAME)}"

  # #
  # # Delete a Zone
  # #
  puts 'Deleting the Zone'
  dns_client.zones.delete(GROUP_NAME, ZONE_NAME)

  # #
  # Delete the Resource Group
  # #
  puts 'Deleting the resource group'
  resource_client.resource_groups.delete(GROUP_NAME)

end

def print_item(group)
  puts "\tName: #{group.name}"
  puts "\tId: #{group.id}"
  puts "\tLocation: #{group.location}"
  puts "\tTags: #{group.tags}"
end

if $0 == __FILE__
  run_example
end


