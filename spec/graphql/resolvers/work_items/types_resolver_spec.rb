# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::WorkItems::TypesResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group)        { create(:group) }
  let_it_be(:project)      { create(:project, group: group) }

  before_all do
    group.add_developer(current_user)
  end

  shared_examples 'a work item type resolver' do
    subject(:result) { resolve(described_class, obj: object) }

    it 'returns all default work item types' do
      expect(result.to_a).to match(WorkItems::Type.default.order_by_name_asc)
    end

    context 'when requesting taskable types' do
      it 'returns only taskable types' do
        result = resolve(described_class, obj: group, args: { taskable: true })

        expect(result.to_a).to contain_exactly(WorkItems::Type.default_by_type(:task))
      end
    end

    context 'when work_items feature flag is disabled' do
      before do
        stub_feature_flags(work_items: false)
      end

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '#resolve' do
    context 'when parent is a group' do
      let(:object) { group }

      it_behaves_like 'a work item type resolver'
    end

    context 'when parent is a project' do
      let(:object) { project }

      it_behaves_like 'a work item type resolver'
    end
  end
end
