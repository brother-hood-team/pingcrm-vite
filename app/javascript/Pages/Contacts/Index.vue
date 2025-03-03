<template>
  <div>
    <h1 class="mb-8 font-bold text-3xl">
      Contacts
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
      <inertia-link
        class="btn-indigo"
        :href="$api.contacts.new.path()"
      >
        Create <span class="hidden md:inline">Contact</span>
      </inertia-link>
    </div>
    <div class="bg-white rounded shadow overflow-x-auto">
      <table class="w-full whitespace-nowrap">
        <thead>
          <tr class="text-left font-bold">
            <th class="px-6 pt-6 pb-4">
              Name
            </th>
            <th class="px-6 pt-6 pb-4">
              Organization
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
            v-for="contact in contacts.data"
            :key="contact.id"
            class="hover:bg-gray-100 focus-within:bg-gray-100"
          >
            <td class="border-t">
              <inertia-link
                class="px-6 py-4 flex items-center focus:text-indigo-500"
                :href="pathToEdit(contact)"
                aria-label="Edit"
              >
                {{ contact.name }}
                <icon
                  v-if="contact.deleted_at"
                  name="trash"
                  class="flex-shrink-0 w-3 h-3 fill-gray-500 ml-2"
                />
              </inertia-link>
            </td>
            <td class="border-t">
              <inertia-link
                class="px-6 py-4 flex items-center"
                :href="pathToEdit(contact)"
                tabindex="-1"
                aria-label="Edit"
              >
                <div v-if="contact.organization">
                  {{ contact.organization.name }}
                </div>
              </inertia-link>
            </td>
            <td class="border-t">
              <inertia-link
                class="px-6 py-4 flex items-center"
                :href="pathToEdit(contact)"
                tabindex="-1"
                aria-label="Edit"
              >
                {{ contact.city }}
              </inertia-link>
            </td>
            <td class="border-t">
              <inertia-link
                class="px-6 py-4 flex items-center"
                :href="pathToEdit(contact)"
                tabindex="-1"
                aria-label="Edit"
              >
                {{ contact.phone }}
              </inertia-link>
            </td>
            <td class="border-t w-px">
              <inertia-link
                class="px-4 flex items-center"
                :href="pathToEdit(contact)"
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
          <tr v-if="contacts.data.length === 0">
            <td
              class="border-t px-6 py-4"
              colspan="4"
            >
              No contacts found.
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <pagination :meta="contacts.meta"/>
  </div>
</template>

<script>
import Icon from '@/Shared/Icon.vue'
import Layout from '@/Layouts/Main.vue'
import mapValues from 'lodash/mapValues'
import Pagination from '@/Shared/Pagination.vue'
import pickBy from 'lodash/pickBy'
import SearchFilter from '@/Shared/SearchFilter.vue'
import throttle from 'lodash/throttle'

import ContactsApi from '@/api/ContactsApi'

export default {
  metaInfo: { title: 'Contacts' },
  components: {
    Icon,
    Pagination,
    SearchFilter,
  },
  layout: Layout,
  props: {
    contacts: {
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
    }
  },
  watch: {
    form: {
      handler: throttle(function () {
        const query = pickBy(this.form)
        ContactsApi.list({
          query: Object.keys(query).length ? query : { remember: 'forget' },
          preserveState: true,
          preserveScroll: true,
          replace: true,
          only: ['contacts'],
        })
      }, 150),
      deep: true,
    },
  },
  methods: {
    pathToEdit (contact) {
      return ContactsApi.edit.path(contact)
    },
    reset () {
      this.form = mapValues(this.form, () => null)
    },
  },
}
</script>
