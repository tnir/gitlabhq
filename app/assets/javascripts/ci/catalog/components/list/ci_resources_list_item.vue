<script>
import {
  GlAvatar,
  GlBadge,
  GlButton,
  GlIcon,
  GlLink,
  GlSprintf,
  GlTooltipDirective,
  GlTruncate,
} from '@gitlab/ui';
import { s__, n__ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { formatDate, getTimeago } from '~/lib/utils/datetime_utility';
import { toNounSeriesText } from '~/lib/utils/grammar';
import { cleanLeadingSeparator } from '~/lib/utils/url_utility';
import Markdown from '~/vue_shared/components/markdown/non_gfm_markdown.vue';
import { CI_RESOURCE_DETAILS_PAGE_NAME } from '../../router/constants';
import { VERIFICATION_LEVEL_UNVERIFIED } from '../../constants';
import CiVerificationBadge from '../shared/ci_verification_badge.vue';

export default {
  i18n: {
    components: s__('CiCatalog|Components:'),
    unreleased: s__('CiCatalog|Unreleased'),
    releasedMessage: s__('CiCatalog|Released %{timeAgo} by %{author}'),
  },
  components: {
    CiVerificationBadge,
    GlAvatar,
    GlBadge,
    GlButton,
    GlIcon,
    GlLink,
    GlSprintf,
    GlTruncate,
    Markdown,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    resource: {
      type: Object,
      required: true,
    },
  },
  computed: {
    authorName() {
      return this.latestVersion.author.name;
    },
    authorUsername() {
      return this.latestVersion.author.username;
    },
    authorId() {
      return getIdFromGraphQLId(this.latestVersion.author.id);
    },
    authorProfileUrl() {
      return this.latestVersion.author.webUrl;
    },
    components() {
      return this.resource.versions?.nodes[0]?.components?.nodes || [];
    },
    componentNamesSprintfMessage() {
      return toNounSeriesText(
        this.components.map((name, index) => `%{componentStart}${index}%{componentEnd}`),
        { onlyCommas: true },
      );
    },
    detailsPageHref() {
      return decodeURIComponent(this.detailsPageResolved.href);
    },
    detailsPageResolved() {
      return this.$router.resolve({
        name: CI_RESOURCE_DETAILS_PAGE_NAME,
        params: { id: this.resourceId },
      });
    },
    entityId() {
      return getIdFromGraphQLId(this.resource.id);
    },
    formattedDate() {
      return formatDate(this.latestVersion?.createdAt);
    },
    hasComponents() {
      return Boolean(this.components.length);
    },
    hasReleasedVersion() {
      return Boolean(this.latestVersion?.createdAt);
    },
    isVerified() {
      return this.resource?.verificationLevel !== VERIFICATION_LEVEL_UNVERIFIED;
    },
    latestVersion() {
      return this.resource?.versions?.nodes[0] || [];
    },
    name() {
      return this.latestVersion?.name || this.$options.i18n.unreleased;
    },
    createdAt() {
      return getTimeago().format(this.latestVersion?.createdAt);
    },
    resourceId() {
      return this.resource?.fullPath;
    },
    starCount() {
      return this.resource?.starCount || 0;
    },
    starCountText() {
      return n__('Star', 'Stars', this.starCount);
    },
    usageCount() {
      return this.resource?.last30DayUsageCount || 0;
    },
    usageText() {
      return s__(
        'CiCatalog|The number of projects that used a component from this project in a pipeline, by using "include:component", in the last 30 days.',
      );
    },
    webPath() {
      return cleanLeadingSeparator(this.resource?.webPath);
    },
    starsHref() {
      return this.resource.starrersPath;
    },
  },
  methods: {
    getComponent(index) {
      return this.components[Number(index)];
    },
    navigateToDetailsPage(e) {
      // Open link in a new tab if any of these modifier key is held down.
      if (e?.ctrlKey || e?.metaKey) {
        return;
      }

      // Override the <a> tag if no modifier key is held down to use Vue router and not
      // open a new tab.
      e.preventDefault();
      // Push to the decoded URL to avoid all the / being encoded
      this.$router.push({ path: decodeURIComponent(this.resourceId) });
    },
  },
};
</script>
<template>
  <li
    class="gl-flex gl-items-center gl-border-b-1 gl-border-gray-100 gl-py-3 gl-text-gray-500 gl-border-b-solid"
    data-testid="catalog-resource-item"
  >
    <gl-avatar
      class="gl-mr-4 gl-self-start"
      :entity-id="entityId"
      :entity-name="resource.name"
      shape="rect"
      :size="48"
      :src="resource.icon"
      @click="navigateToDetailsPage"
    />
    <div class="gl-flex gl-grow gl-flex-col">
      <div>
        <span class="gl-mb-1 gl-text-sm">{{ webPath }}</span>
        <ci-verification-badge
          v-if="isVerified"
          :resource-id="resource.id"
          :verification-level="resource.verificationLevel"
        />
      </div>
      <div class="gl-mb-1 gl-flex gl-flex-wrap gl-gap-2">
        <gl-link
          class="gl-mr-1 !gl-text-gray-900"
          :href="detailsPageHref"
          data-testid="ci-resource-link"
          @click="navigateToDetailsPage"
        >
          <b> {{ resource.name }}</b>
        </gl-link>
        <div class="gl-flex gl-grow md:gl-justify-between">
          <gl-badge class="gl-h-5 gl-self-center" variant="info">{{ name }}</gl-badge>
          <div class="gl-ml-3 gl-flex gl-items-center">
            <div v-gl-tooltip.top class="gl-mr-3 gl-flex gl-items-center" :title="usageText">
              <gl-icon name="chart" :size="16" />
              <span class="gl-ml-2" data-testid="stats-usage">
                {{ usageCount }}
              </span>
            </div>
            <gl-button
              v-gl-tooltip.top
              data-testid="stats-favorites"
              class="!gl-text-inherit"
              icon="star-o"
              :title="starCountText"
              :href="starsHref"
              size="small"
              variant="link"
            >
              {{ starCount }}
            </gl-button>
          </div>
        </div>
      </div>
      <div class="gl-flex gl-flex-col gl-justify-between gl-gap-2 gl-text-sm md:gl-flex-row">
        <div>
          <markdown class="gl-flex gl-basis-2/3" :markdown="resource.description" />
          <div
            v-if="hasComponents"
            data-testid="ci-resource-component-names"
            class="gl-mt-1 gl-inline-flex gl-flex-wrap gl-text-sm gl-text-gray-900"
          >
            <span class="gl-font-bold"> &#8226; {{ $options.i18n.components }} </span>
            <gl-sprintf :message="componentNamesSprintfMessage">
              <template #component="{ content }">
                <gl-truncate
                  class="gl-ml-2 gl-max-w-30"
                  :text="getComponent(content).name"
                  position="end"
                  with-tooltip
                />
              </template>
            </gl-sprintf>
          </div>
        </div>
        <div class="gl-flex gl-shrink-0 gl-justify-end">
          <div v-if="hasReleasedVersion" class="gl-shrink-0">
            <gl-sprintf :message="$options.i18n.releasedMessage">
              <template #timeAgo>
                <span v-gl-tooltip.top :title="formattedDate">
                  {{ createdAt }}
                </span>
              </template>
              <template #author>
                <gl-link
                  :data-name="authorName"
                  :data-user-id="authorId"
                  :data-username="authorUsername"
                  data-testid="user-link"
                  :href="authorProfileUrl"
                  class="js-user-link"
                >
                  <span>{{ authorName }}</span>
                </gl-link>
              </template>
            </gl-sprintf>
          </div>
        </div>
      </div>
    </div>
  </li>
</template>
