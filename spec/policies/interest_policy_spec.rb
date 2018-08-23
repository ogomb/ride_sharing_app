require "rails_helper"

RSpec.describe InterestPolicy do
  context "permissions" do
    subject {  InterestPolicy.new(user, interest) }

    let(:user) { FactoryGirl.create(:user) }
    let(:ride) { FactoryGirl.create(:ride, destination: "Nairobi", checkout: "18:00", passengers: 4) }
    let(:interest) { FactoryGirl.create(:interest, ride: ride,author: user) }

    context "for viewers of the ride" do
      before { assign_role!(user, :viewer, ride) }
      it { should permit_action :show }
      it { should_not permit_action :create }
      it { should_not permit_action :update }
    end

    context "for editors of the ride" do
      before { assign_role!(user, :editor, ride) }
      it { should permit_action :show }
      it { should permit_action :create }

    end

    context "for drivers of the ride" do
      before { assign_role!(user, :driver, ride) }
    it { should permit_action :show }
      it { should permit_action :create }
      it { should permit_action :update }
    end

  context "for drivers of other rides" do
    before do
      assign_role!(user, :driver, FactoryGirl.create(:ride, destination: "Kisumu", checkout: "18:00", passengers: 4))
    end
    it { should_not permit_action :show }
    it { should_not permit_action :create }
    it { should_not permit_action :update }
  end

  context "for administrators" do
    let(:user) { FactoryGirl.create :user, :admin }
    it { should permit_action :show }
    it { should permit_action :create }
    it { should permit_action :update }
  end
end
end