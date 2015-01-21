# encoding: utf-8
require 'spec_helper'

# test applications
module Admin
  class AccountPage; Route << self end
  class PersonPage; Route << self end
end

module API
  class AccountPage; Route << self end
end

class AccountPage; Route << self end

class Account
  attr_accessor :tid
  def initialize(tid)
    @tid = tid
  end
end

describe Route do
  describe '.to' do
    describe AccountPage do
      it('mount to /accounts') do
        Route << AccountPage
        expect(Route.to(AccountPage)).to eq('/accounts')

        Route[AccountPage] = '/valid'
        expect(Route.to(AccountPage, 'signin')).to eq('/valid/signin')
        expect(Route.to(AccountPage, :signout)).to eq('/valid/signout')
      end
    end

    describe Admin::AccountPage do
      it 'mount to /admin/accounts' do
        Route << Admin::AccountPage
        expect(Route.to(Admin::AccountPage)).to eq('/admin/accounts')
      end
    end

    describe Admin::PersonPage do
      it 'mount to /admin/people' do
        Route << Admin::PersonPage
        expect(Route.to(Admin::PersonPage)).to eq('/admin/people')
      end
    end

    describe API::AccountPage do
      it 'mount to /api/accounts' do
        Route << API::AccountPage
        expect(Route.to(API::AccountPage)).to eq('/api/accounts')
      end

      it 'accept end points with extra parts' do
        expect(Route.to(API::AccountPage, :user)).to eq('/api/accounts/user')
        expect(Route.to(API::AccountPage, Account.new('129423'))).to eq('/api/accounts/129423')
        expect(Route.to(API::AccountPage, 'Settings')).to eq('/api/accounts/settings')
      end
    end

    describe '.all' do
      it 'should mount properly' do
        expect(Route.all['/api/accounts']).to be_instance_of(API::AccountPage)
      end
    end
  end

  describe '[]' do
    it 'return application class for a string key' do
      expect(Route[Route.to(Admin::PersonPage)]).to eq(Admin::PersonPage)
      expect(Route[Route.to(Admin::AccountPage)]).to eq(Admin::AccountPage)
    end

    it 'return the string path for a class key' do
      expect(Route[Admin::PersonPage]).to eq(Route.to(Admin::PersonPage))
      expect(Route[Admin::AccountPage]).to eq(Route.to(Admin::AccountPage))
    end
  end
end
