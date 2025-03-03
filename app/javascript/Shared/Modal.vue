<!-- Source: https://github.com/adamwathan/vue-tailwind-examples -->

<template>
  <portal to="modal">
    <div
      v-if="showModal"
      class="fixed inset-0"
    >
      <transition
        enterActiveClass="transition-all transition-fast ease-out-quad"
        leaveActiveClass="transition-all transition-medium ease-in-quad"
        enterClass="opacity-0"
        enterToClass="opacity-100"
        leaveClass="opacity-100"
        leaveToClass="opacity-0"
        appear
        @before-leave="backdropLeaving = true"
        @after-leave="backdropLeaving = false"
      >
        <div v-if="showBackdrop">
          <div class="fixed inset-0 bg-black opacity-50"/>
        </div>
      </transition>

      <transition
        enterActiveClass="transition-all transition-fast ease-out-quad"
        leaveActiveClass="transition-all transition-medium ease-in-quad"
        enterClass="opacity-0 scale-70"
        enterToClass="opacity-100 scale-100"
        leaveClass="opacity-100 scale-100"
        leaveToClass="opacity-0 scale-70"
        appear
        @before-leave="cardLeaving = true"
        @after-leave="cardLeaving = false"
      >
        <div
          v-if="showContent"
          class="relative h-full overflow-y-auto text-center"
          @click="close"
        >
          <div class="absolute inline-block align-middle w-0 h-screen"/>

          <div
            class="inline-block align-middle text-left my-6 rounded overflow-hidden"
            @click.stop
          >
            <div class="px-8 py-4 bg-gray-100 border-b border-gray-200 flex justify-between items-center">
              <h1 class="font-bold text-xl">
                {{ title }}
              </h1>

              <button
                type="button"
                class="p-1 rounded hover:bg-gray-300"
                title="Close"
                @click="close"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-4 h-4"
                  viewBox="0 0 20 20"
                >
                  <path d="M10 8.59L2.93 1.51 1.51 2.93 8.59 10l-7.08 7.07 1.42 1.42L10 11.41l7.07 7.08 1.42-1.42L11.41 10l7.08-7.07-1.42-1.42L10 8.59z"/>
                </svg>
              </button>
            </div>

            <slot/>
          </div>
        </div>
      </transition>
    </div>
  </portal>
</template>

<script>
export default {
  props: {
    open: {
      type: Boolean,
      default: false,
    },
    title: {
      type: String,
      default: null,
    },
  },
  data () {
    return {
      showModal: false,
      showBackdrop: false,
      showContent: false,
      backdropLeaving: false,
      cardLeaving: false,
    }
  },
  computed: {
    leaving () {
      return this.backdropLeaving || this.cardLeaving
    },
  },
  watch: {
    open: {
      handler (newValue) {
        if (newValue)
          this.show()
        else
          this.close()
      },
      immediate: true,
    },
    leaving (newValue) {
      if (newValue === false) {
        this.showModal = false
        this.$emit('close')
      }
    },
  },
  mounted () {
    const onEscape = (e) => {
      if (this.open && e.keyCode === 27)
        this.close()
    }
    document.addEventListener('keydown', onEscape)
    this.$once('hook:destroyed', () => {
      document.removeEventListener('keydown', onEscape)
    })
  },
  methods: {
    show () {
      this.showModal = true
      this.showBackdrop = true
      this.showContent = true
      if (!import.meta.env.SSR) document.body.style.setProperty('overflow', 'hidden')
    },
    close () {
      this.showBackdrop = false
      this.showContent = false
      if (!import.meta.env.SSR) document.body.style.removeProperty('overflow')
    },
  },
}
</script>
