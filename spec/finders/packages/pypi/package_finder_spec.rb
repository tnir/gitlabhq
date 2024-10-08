# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Pypi::PackageFinder, feature_category: :package_registry do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:project2) { create(:project, group: group) }
  let_it_be(:package1) { create(:pypi_package, project: project) }
  let_it_be(:package2) { create(:pypi_package, project: project) }
  let_it_be(:package3) { create(:pypi_package, project: project2) }

  let(:package_file) { package2.package_files.first }
  let(:params) do
    {
      filename: package_file.file_name,
      sha256: package_file.file_sha256
    }
  end

  describe 'execute' do
    subject { described_class.new(user, scope, params).execute }

    context 'within a project' do
      let(:scope) { project }

      it { is_expected.to eq(package2) }
    end

    context 'within a group' do
      let(:scope) { group }

      it { is_expected.to eq(package2) }
    end

    context 'when pypi_extract_package_model is disabled' do
      before do
        stub_feature_flags(pypi_extract_pypi_package_model: false)
      end

      context 'within a project' do
        let(:scope) { project }

        # rubocop:disable Cop/AvoidBecomes -- implementing inheritance for PyPi packages https://gitlab.com/gitlab-org/gitlab/-/issues/435827
        it { is_expected.to eq(package2.becomes(::Packages::Package)) }
        # rubocop:enable Cop/AvoidBecomes
      end

      context 'within a group' do
        let(:scope) { group }

        # rubocop:disable Cop/AvoidBecomes -- implementing inheritance for PyPi packages https://gitlab.com/gitlab-org/gitlab/-/issues/435827
        it { is_expected.to eq(package2.becomes(::Packages::Package)) }
        # rubocop:enable Cop/AvoidBecomes
      end
    end
  end
end
