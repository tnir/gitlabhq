<script>
import {
  GlBadge,
  GlButton,
  GlModal,
  GlModalDirective,
  GlTooltipDirective,
  GlLink,
  GlEmptyState,
  GlTab,
  GlTabs,
  GlTable,
  GlSprintf,
} from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import Tracking from '~/tracking';
import PackageHistory from './package_history.vue';
import PackageTitle from './package_title.vue';
import PackagesListLoader from '../../shared/components/packages_list_loader.vue';
import PackageListRow from '../../shared/components/package_list_row.vue';
import DependencyRow from './dependency_row.vue';
import AdditionalMetadata from './additional_metadata.vue';
import InstallationCommands from './installation_commands.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import FileIcon from '~/vue_shared/components/file_icon.vue';
import { __, s__ } from '~/locale';
import { PackageType, TrackingActions } from '../../shared/constants';
import { packageTypeToTrackCategory } from '../../shared/utils';

export default {
  name: 'PackagesApp',
  components: {
    GlBadge,
    GlButton,
    GlEmptyState,
    GlLink,
    GlModal,
    GlTab,
    GlTabs,
    GlTable,
    FileIcon,
    GlSprintf,
    PackageTitle,
    PackagesListLoader,
    PackageListRow,
    DependencyRow,
    PackageHistory,
    AdditionalMetadata,
    InstallationCommands,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    GlModal: GlModalDirective,
  },
  mixins: [timeagoMixin, Tracking.mixin()],
  trackingActions: { ...TrackingActions },
  computed: {
    ...mapState([
      'projectName',
      'packageEntity',
      'packageFiles',
      'isLoading',
      'canDelete',
      'destroyPath',
      'svgPath',
      'npmPath',
      'npmHelpPath',
    ]),
    isValidPackage() {
      return Boolean(this.packageEntity.name);
    },
    canDeletePackage() {
      return this.canDelete && this.destroyPath;
    },
    filesTableRows() {
      return this.packageFiles.map(x => ({
        name: x.file_name,
        downloadPath: x.download_path,
        size: this.formatSize(x.size),
        created: x.created_at,
      }));
    },
    tracking() {
      return {
        category: packageTypeToTrackCategory(this.packageEntity.package_type),
      };
    },
    hasVersions() {
      return this.packageEntity.versions?.length > 0;
    },
    packageDependencies() {
      return this.packageEntity.dependency_links || [];
    },
    showDependencies() {
      return this.packageEntity.package_type === PackageType.NUGET;
    },
    showFiles() {
      return this.packageEntity?.package_type !== PackageType.COMPOSER;
    },
  },
  methods: {
    ...mapActions(['fetchPackageVersions']),
    formatSize(size) {
      return numberToHumanSize(size);
    },
    cancelDelete() {
      this.$refs.deleteModal.hide();
    },
    getPackageVersions() {
      if (!this.packageEntity.versions) {
        this.fetchPackageVersions();
      }
    },
  },
  i18n: {
    deleteModalTitle: s__(`PackageRegistry|Delete Package Version`),
    deleteModalContent: s__(
      `PackageRegistry|You are about to delete version %{version} of %{name}. Are you sure?`,
    ),
  },
  filesTableHeaderFields: [
    {
      key: 'name',
      label: __('Name'),
      tdClass: 'd-flex align-items-center',
    },
    {
      key: 'size',
      label: __('Size'),
    },
    {
      key: 'created',
      label: __('Created'),
      class: 'text-right',
    },
  ],
};
</script>

<template>
  <gl-empty-state
    v-if="!isValidPackage"
    :title="s__('PackageRegistry|Unable to load package')"
    :description="s__('PackageRegistry|There was a problem fetching the details for this package.')"
    :svg-path="svgPath"
  />

  <div v-else class="packages-app">
    <div class="detail-page-header d-flex justify-content-between flex-column flex-sm-row">
      <package-title />

      <div class="mt-sm-2">
        <gl-button
          v-if="canDeletePackage"
          v-gl-modal="'delete-modal'"
          class="js-delete-button"
          variant="danger"
          category="primary"
          data-qa-selector="delete_button"
        >
          {{ __('Delete') }}
        </gl-button>
      </div>
    </div>

    <gl-tabs>
      <gl-tab :title="__('Detail')">
        <div data-qa-selector="package_information_content">
          <package-history :package-entity="packageEntity" :project-name="projectName" />

          <installation-commands
            :package-entity="packageEntity"
            :npm-path="npmPath"
            :npm-help-path="npmHelpPath"
          />

          <additional-metadata :package-entity="packageEntity" />
        </div>

        <template v-if="showFiles">
          <h3 class="gl-font-lg gl-mt-5">{{ __('Files') }}</h3>
          <gl-table
            :fields="$options.filesTableHeaderFields"
            :items="filesTableRows"
            tbody-tr-class="js-file-row"
          >
            <template #cell(name)="{ item }">
              <gl-link
                :href="item.downloadPath"
                class="js-file-download gl-relative"
                @click="track($options.trackingActions.PULL_PACKAGE)"
              >
                <file-icon
                  :file-name="item.name"
                  css-classes="gl-relative file-icon"
                  class="gl-mr-1 gl-relative"
                />
                <span class="gl-relative">{{ item.name }}</span>
              </gl-link>
            </template>

            <template #cell(created)="{ item }">
              <span v-gl-tooltip :title="tooltipTitle(item.created)">{{
                timeFormatted(item.created)
              }}</span>
            </template>
          </gl-table>
        </template>
      </gl-tab>

      <gl-tab v-if="showDependencies" title-item-class="js-dependencies-tab">
        <template #title>
          <span>{{ __('Dependencies') }}</span>
          <gl-badge size="sm" data-testid="dependencies-badge">{{
            packageDependencies.length
          }}</gl-badge>
        </template>

        <template v-if="packageDependencies.length > 0">
          <dependency-row
            v-for="(dep, index) in packageDependencies"
            :key="index"
            :dependency="dep"
          />
        </template>

        <p v-else class="gl-mt-3" data-testid="no-dependencies-message">
          {{ s__('PackageRegistry|This NuGet package has no dependencies.') }}
        </p>
      </gl-tab>

      <gl-tab
        :title="__('Other versions')"
        title-item-class="js-versions-tab"
        @click="getPackageVersions"
      >
        <template v-if="isLoading && !hasVersions">
          <packages-list-loader />
        </template>

        <template v-else-if="hasVersions">
          <package-list-row
            v-for="v in packageEntity.versions"
            :key="v.id"
            :package-entity="{ name: packageEntity.name, ...v }"
            :package-link="v.id.toString()"
            :disable-delete="true"
            :show-package-type="false"
          />
        </template>

        <p v-else class="gl-mt-3" data-testid="no-versions-message">
          {{ s__('PackageRegistry|There are no other versions of this package.') }}
        </p>
      </gl-tab>
    </gl-tabs>

    <gl-modal ref="deleteModal" class="js-delete-modal" modal-id="delete-modal">
      <template #modal-title>{{ $options.i18n.deleteModalTitle }}</template>
      <gl-sprintf :message="$options.i18n.deleteModalContent">
        <template #version>
          <strong>{{ packageEntity.version }}</strong>
        </template>

        <template #name>
          <strong>{{ packageEntity.name }}</strong>
        </template>
      </gl-sprintf>

      <div slot="modal-footer" class="w-100">
        <div class="float-right">
          <gl-button @click="cancelDelete()">{{ __('Cancel') }}</gl-button>
          <gl-button
            ref="modal-delete-button"
            data-method="delete"
            :to="destroyPath"
            variant="danger"
            category="primary"
            data-qa-selector="delete_modal_button"
            @click="track($options.trackingActions.DELETE_PACKAGE)"
          >
            {{ __('Delete') }}
          </gl-button>
        </div>
      </div>
    </gl-modal>
  </div>
</template>
