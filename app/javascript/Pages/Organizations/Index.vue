<template>
  <div>
    <h1 class="mb-8 font-bold text-3xl">
      Organizations
    </h1>
    <div class="mb-6 flex justify-between items-center">
      <search-filter
        v-model="form.search"
        class="w-full max-w-md mr-4"
        @reset="reset"
      >
        <label
          class="block text-gray-800"
          for="trashed-filter"
        >Trashed:</label>
        <select
          id="trashed-filter"
          v-model="form.trashed"
          class="mt-1 w-full form-select"
        >
          <option :value="null"/>
          <option value="with">
            With Trashed
          </option>
          <option value="only">
            Only Trashed
          </option>
        </select>
      </search-filter>

      <button
        class="btn-indigo"
        @click="modalNew = true"
      >
        Create <span class="hidden md:inline">Organization</span>
      </button>
      <modal
        :open="modalNew"
        title="Create Organization"
        @close="modalNew = false"
      >
        <new-organization @success="modalNew = false"/>
      </modal>
    </div>
    <div class="bg-white rounded shadow overflow-x-auto">
      <table class="w-full whitespace-nowrap">
        <thead>
          <tr class="text-left font-bold">
            <th class="px-6 pt-6 pb-4">
              Name
            </th>
            <th class="px-6 pt-6 pb-4">
              City
            </th>
            <th
              class="px-6 pt-6 pb-4"
              colspan="2"
            >
              Phone
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="organization in organizations.data"
            :key="organization.id"
            class="hover:bg-gray-100 focus-within:bg-gray-100"
          >
            <td class="border-t">
              <inertia-link
                class="px-6 py-4 flex items-center focus:text-indigo-500"
                :href="pathToEdit(organization)"
              >
                {{ organization.name }}
                <icon
                  v-if="organization.deleted_at"
                  name="trash"
                  class="flex-shrink-0 w-3 h-3 fill-gray-500 ml-2"
                />
              </inertia-link>
            </td>
            <td class="border-t">
              <inertia-link
                class="px-6 py-4 flex items-center"
                :href="pathToEdit(organization)"
                tabindex="-1"
                aria-label="Edit"
              >
                {{ organization.city }}
              </inertia-link>
            </td>
            <td class="border-t">
              <inertia-link
                class="px-6 py-4 flex items-center"
                :href="pathToEdit(organization)"
                tabindex="-1"
                aria-label="Edit"
              >
                {{ organization.phone }}
              </inertia-link>
            </td>
            <td class="border-t w-px">
              <inertia-link
                class="px-4 flex items-center"
                :href="pathToEdit(organization)"
                tabindex="-1"
                aria-label="Edit"
              >
                <icon
                  name="cheveron-right"
                  class="block w-6 h-6 fill-gray-500"
                />
              </inertia-link>
            </td>
          </tr>
          <tr v-if="organizations.data.length === 0">
            <td
              class="border-t px-6 py-4"
              colspan="4"
            >
              No organizations found.
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <pagination :meta="organizations.meta"/>
  </div>
</template>

<script>
import Icon from '@/Shared/Icon.vue'
import Layout from '@/Layouts/Main.vue'
import mapValues from 'lodash/mapValues'
import Pagination from '@/Shared/Pagination.vue'
import pickBy from 'lodash/pickBy'
import SearchFilter from '@/Shared/SearchFilter.vue'
import Modal from '@/Shared/Modal.vue'
import NewOrganization from '@/Pages/Organizations/_New.vue'
import throttle from 'lodash/throttle'
import OrganizationsApi from '@/api/OrganizationsApi'

export default {
  metaInfo: { title: 'Organizations' },
  components: {
    Icon,
    Pagination,
    SearchFilter,
    Modal,
    NewOrganization,
  },
  layout: Layout,
  props: {
    organizations: {
      type: Object,
      required: true,
    },
    filters: {
      type: Object,
      required: true,
    },
  },
  data () {
    return {
      form: {
        search: this.filters.search,
        trashed: this.filters.trashed,
      },
      modalNew: false,
    }
  },
  watch: {
    form: {
      handler: throttle(function () {
        const query = pickBy(this.form)
        OrganizationsApi.list({
          query: Object.keys(query).length ? query : { remember: 'forget' },
          preserveState: true,
          preserveScroll: true,
          replace: true,
          only: ['organizations'],
        })
      }, 150),
      deep: true,
    },
  },
  methods: {
    pathToEdit (organization) {
      return OrganizationsApi.edit.path(organization)
    },
    reset () {
      this.form = mapValues(this.form, () => null)
    },
  },
}
</script>
