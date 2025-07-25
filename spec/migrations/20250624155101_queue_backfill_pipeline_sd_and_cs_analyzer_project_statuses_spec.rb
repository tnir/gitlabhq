# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe QueueBackfillPipelineSdAndCsAnalyzerProjectStatuses, migration: :gitlab_sec, feature_category: :security_asset_inventories do
  let!(:batched_migration) { described_class::MIGRATION }

  it 'schedules a new batched migration' do
    reversible_migration do |migration|
      migration.before -> {
        expect(batched_migration).not_to have_scheduled_batched_migration
      }

      migration.after -> {
        expect(batched_migration).to have_scheduled_batched_migration(
          gitlab_schema: :gitlab_sec,
          table_name: :analyzer_project_statuses,
          column_name: :id,
          interval: described_class::DELAY_INTERVAL,
          batch_size: described_class::BATCH_SIZE,
          sub_batch_size: described_class::SUB_BATCH_SIZE
        )
      }
    end
  end
end
