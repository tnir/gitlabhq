# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting a list of work item types for a group', feature_category: :team_planning do
  include GraphqlHelpers

  let_it_be(:namespace) { create(:group, :private) }
  let_it_be(:developer) { create(:user, developer_of: namespace) }

  it_behaves_like 'graphql work item type list request spec' do
    let(:current_user) { developer }
    let(:parent) { namespace }
  end
end
