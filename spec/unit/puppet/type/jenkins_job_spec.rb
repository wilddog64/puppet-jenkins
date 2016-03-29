require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_job) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end
  end #parameters

  describe 'properties' do
    describe 'ensure' do
      it_behaves_like 'generic ensurable'
    end

    describe 'enable' do
      it_behaves_like 'boolean property', :enable, true
    end

    # unvalidated properties
    [:config].each do |property|
      describe "#{property}" do
        it { expect(described_class.attrtype(property)).to eq :property }
      end
    end
  end #properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'

    describe 'folders' do
      it "should autorequire parent folder resource" do
        folder = described_class.new(
          :name => 'foo',
        )

        job = described_class.new(
          :name => 'foo/bar',
        )

        folder[:ensure] = :present
        job[:ensure] = :present

        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource folder
        catalog.add_resource job
        req = job.autorequire

        expect(req.size).to eq 1
        expect(req[0].source).to eq folder
        expect(req[0].target).to eq job
      end

      it "should autorequire multiple nested parent folder resources" do
        folder1 = described_class.new(
          :name => 'foo',
        )

        folder2 = described_class.new(
          :name => 'foo/bar',
        )

        job = described_class.new(
          :name => 'foo/bar/baz',
        )

        folder1[:ensure] = :present
        folder2[:ensure] = :present
        job[:ensure] = :present

        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource folder1
        catalog.add_resource folder2
        catalog.add_resource job
        req = job.autorequire

        expect(req.size).to eq 2
        expect(req[0].source).to eq folder1
        expect(req[0].target).to eq job
        expect(req[1].source).to eq folder2
        expect(req[1].target).to eq job
      end
    end # folders
  end # autorequire
end
