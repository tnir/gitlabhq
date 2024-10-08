<script>
import {
  GlLabel,
  GlLink,
  GlIcon,
  GlButton,
  GlAvatar,
  GlAvatarLink,
  GlAvatarsInline,
  GlTooltip,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import { isScopedLabel } from '~/lib/utils/common_utils';
import RichTimestampTooltip from '~/vue_shared/components/rich_timestamp_tooltip.vue';
import WorkItemLinkChildMetadata from 'ee_else_ce/work_items/components/shared/work_item_link_child_metadata.vue';
import WorkItemTypeIcon from '../work_item_type_icon.vue';
import WorkItemStateBadge from '../work_item_state_badge.vue';
import { findLinkedItemsWidget } from '../../utils';
import { STATE_OPEN, WIDGET_TYPE_ASSIGNEES, WIDGET_TYPE_LABELS } from '../../constants';
import WorkItemRelationshipIcons from './work_item_relationship_icons.vue';

export default {
  i18n: {
    confidential: __('Confidential'),
    created: __('Created'),
    closed: __('Closed'),
    remove: s__('WorkItem|Remove'),
  },
  components: {
    GlLabel,
    GlLink,
    GlIcon,
    GlButton,
    GlAvatar,
    GlAvatarLink,
    GlAvatarsInline,
    GlTooltip,
    RichTimestampTooltip,
    WorkItemLinkChildMetadata,
    WorkItemTypeIcon,
    WorkItemStateBadge,
    WorkItemRelationshipIcons,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    childItem: {
      type: Object,
      required: true,
    },
    canUpdate: {
      type: Boolean,
      required: true,
    },
    showLabels: {
      type: Boolean,
      required: false,
      default: true,
    },
    workItemFullPath: {
      type: String,
      required: false,
      default: '',
    },
    showWeight: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    labels() {
      return this.metadataWidgets[WIDGET_TYPE_LABELS]?.labels?.nodes || [];
    },
    metadataWidgets() {
      return this.childItem.widgets?.reduce((metadataWidgets, widget) => {
        if (widget.type) {
          // eslint-disable-next-line no-param-reassign
          metadataWidgets[widget.type] = widget;
        }
        return metadataWidgets;
      }, {});
    },
    assignees() {
      return this.metadataWidgets[WIDGET_TYPE_ASSIGNEES]?.assignees?.nodes || [];
    },
    assigneesCollapsedTooltip() {
      if (this.assignees.length > 2) {
        return sprintf(s__('WorkItem|%{count} more assignees'), {
          count: this.assignees.length - 2,
        });
      }
      return '';
    },
    allowsScopedLabels() {
      return this.metadataWidgets[WIDGET_TYPE_LABELS]?.allowsScopedLabels;
    },
    isChildItemOpen() {
      return this.childItem.state === STATE_OPEN;
    },
    childItemType() {
      return this.childItem.workItemType.name;
    },
    stateTimestamp() {
      return this.isChildItemOpen ? this.childItem.createdAt : this.childItem.closedAt;
    },
    stateTimestampTypeText() {
      return this.isChildItemOpen ? this.$options.i18n.created : this.$options.i18n.closed;
    },
    childItemTypeColorClass() {
      return this.isChildItemOpen ? 'gl-text-secondary' : 'gl-text-gray-300';
    },
    displayLabels() {
      return this.showLabels && this.labels.length;
    },
    displayReference() {
      // The reference is replaced by work item fullpath in case the project and group are same.
      // e.g., gitlab-org/gitlab-test#45 will be shown as #45
      if (new RegExp(`${this.workItemFullPath}#`, 'g').test(this.childItem.reference)) {
        return this.childItem.reference.replace(new RegExp(`${this.workItemFullPath}`, 'g'), '');
      }
      return this.childItem.reference;
    },
    linkedChildWorkItems() {
      return findLinkedItemsWidget(this.childItem).linkedItems?.nodes || [];
    },
  },
  methods: {
    showScopedLabel(label) {
      return isScopedLabel(label) && this.allowsScopedLabels;
    },
  },
};
</script>

<template>
  <div
    class="item-body work-item-link-child gl-relative gl-flex gl-min-w-0 gl-grow gl-gap-3 gl-hyphens-auto gl-break-words gl-rounded-base gl-p-3"
    data-testid="links-child"
  >
    <div ref="stateIcon" class="gl-cursor-help">
      <work-item-type-icon :color-class="childItemTypeColorClass" :work-item-type="childItemType" />
      <gl-tooltip :target="() => $refs.stateIcon">
        {{ childItemType }}
      </gl-tooltip>
    </div>
    <div class="gl-flex gl-min-w-0 gl-grow gl-flex-col gl-flex-wrap">
      <div class="gl-mb-2 gl-flex gl-min-w-0 gl-justify-between gl-gap-3">
        <div class="item-title gl-min-w-0">
          <span v-if="childItem.confidential">
            <gl-icon
              v-gl-tooltip.top
              name="eye-slash"
              class="gl-text-orange-500"
              data-testid="confidential-icon"
              :aria-label="$options.i18n.confidential"
              :title="$options.i18n.confidential"
            />
          </span>
          <gl-link
            :href="childItem.webUrl"
            :class="{ '!gl-text-secondary': !isChildItemOpen }"
            class="gl-hyphens-auto gl-break-words gl-font-semibold"
            @click.exact="$emit('click', $event)"
            @mouseover="$emit('mouseover')"
            @mouseout="$emit('mouseout')"
          >
            {{ childItem.title }}
          </gl-link>
        </div>
        <div class="gl-flex gl-shrink-0 gl-items-center gl-justify-end gl-gap-3">
          <gl-avatars-inline
            v-if="assignees.length"
            :avatars="assignees"
            collapsed
            :max-visible="2"
            :avatar-size="16"
            badge-tooltip-prop="name"
            :badge-sr-only-text="assigneesCollapsedTooltip"
          >
            <template #avatar="{ avatar }">
              <gl-avatar-link v-gl-tooltip :href="avatar.webUrl" :title="avatar.name">
                <gl-avatar :alt="avatar.name" :src="avatar.avatarUrl" :size="16" />
              </gl-avatar-link>
            </template>
          </gl-avatars-inline>
          <work-item-relationship-icons
            v-if="isChildItemOpen && linkedChildWorkItems.length"
            :work-item-type="childItemType"
            :linked-work-items="linkedChildWorkItems"
          />
          <span
            :id="`statusIcon-${childItem.id}`"
            class="gl-cursor-help"
            data-testid="item-status-icon"
          >
            <work-item-state-badge :work-item-state="childItem.state" :show-icon="false" />
          </span>
          <rich-timestamp-tooltip
            :target="`statusIcon-${childItem.id}`"
            :raw-timestamp="stateTimestamp"
            :timestamp-type-text="stateTimestampTypeText"
          />
        </div>
      </div>
      <work-item-link-child-metadata
        :reference="displayReference"
        :iid="childItem.iid"
        :is-child-item-open="isChildItemOpen"
        :metadata-widgets="metadataWidgets"
        :show-weight="showWeight"
        :work-item-type="childItemType"
        class="ml-xl-0"
      />
      <div v-if="displayLabels" class="gl-flex gl-flex-wrap">
        <gl-label
          v-for="label in labels"
          :key="label.id"
          :title="label.title"
          :background-color="label.color"
          :description="label.description"
          :scoped="showScopedLabel(label)"
          class="gl-mb-auto gl-mr-2 gl-mt-2"
          tooltip-placement="top"
        />
      </div>
    </div>
    <div v-if="canUpdate">
      <gl-button
        v-gl-tooltip
        class="-gl-mr-1 -gl-mt-1"
        category="tertiary"
        size="small"
        icon="close"
        :aria-label="$options.i18n.remove"
        :title="$options.i18n.remove"
        data-testid="remove-work-item-link"
        @click="$emit('removeChild', childItem)"
      />
    </div>
  </div>
</template>
