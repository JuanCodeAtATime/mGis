<template>
  <div>
    <div v-if="C_editForManager" class="blur_show text-center">
      <div class="text-danger d-flex align-items-center">
        <p class="mr-2 mb-0">Details</p>
        <i class="fas fa-long-arrow-alt-right"></i>
      </div>
    </div>
    <div v-if="!loading" class="notes_show mb-5 mx-2" :class="{'hide-to-edit': C_editForManager}">
      <div v-if="show">
        <div class="crud-actions mx-3 float-right">
          <span v-if="permitted('write')" class="mr-2 font-sm edit-action" @click.stop="editNoteMode">
            <i class="fas fa-edit"></i>
          </span>
          <span v-if="permitted('delete')" class="font-sm delete-action" @click.stop="deleteNote">
            <i class="fas fa-trash-alt"></i>
          </span>
        </div>
        <div class="note_by my-2">
          <span class="badge badge-secondary">Note by</span>
          <span class="text-muted font-sm">{{noteBy}}</span>
        </div>
        <div v-if="DV_note.attachFiles.length > 0" class="note_files">
          <span class="badge badge-secondary mr-3">Note Files</span>
          <span v-for="file in DV_note.attachFiles">
            <span class="file-icon" v-tooltip.bottom="`${file.name}`" @click="downloadFile(file)">
              <i class="fas fa-file-alt"></i>
            </span>
          </span>
        </div>
        <div class="note_body my-2 font-sm">
          {{DV_note.body}}
        </div>
      </div>
      <div v-else>
        <notes-form
          v-if="permitted('write')"
          title="Edit Note"
          :note="DV_note"
          :facility="facility"
          @close-note-input="show=true"
          @note-updated="noteUpdated"
        />
      </div>
    </div>

  </div>
</template>

<script>
  import http from './../../../common/http'
  import NotesForm from './notes_form'
  import {mapGetters, mapMutations} from 'vuex'

  export default {
    props: ['facility', 'note', 'from'],
    components: {NotesForm},
    data() {
      return {
        show: true,
        loading: true,
        DV_note: null
      }
    },
    mounted() {
      if (!_.isEmpty(this.note)) {
        this.loading = false
        this.DV_note = this.note
      }
    },
    methods: {
      ...mapMutations([
        'setTaskForManager'
      ]),
      editNoteMode() {
        if (this.from == "manager_view") {
          this.setTaskForManager({key: 'note', value: this.DV_note})
        } else {
          this.show = false
        }
      },
      noteUpdated(note) {
        this.show = true
        this.$emit('note-updated', note)
      },
      deleteNote() {
        var confirm = window.confirm(`Are you sure, you want to delete this note?`)
        if (!confirm) return;

        http
          .delete(`/projects/${this.currentProject.id}/facilities/${this.facility.id}/notes/${this.note.id}.json`)
          .then((res) => {
            this.loading = false
            this.$emit('note-deleted', this.note)
          })
          .catch((err) => {
            this.loading = false
            console.error(err)
          })
      },
      downloadFile(file) {
        if (this._isallowed('write')) {
          let url = window.location.origin + file.uri
          window.open(url, '_blank')
        }
      }
    },
    computed: {
      ...mapGetters([
        'currentProject',
        'managerView'
      ]),
      noteBy() {
        if (this.loading) return null
        return `${this.DV_note.user.firstName} ${this.DV_note.user.lastName} at ${new Date(this.DV_note.createdAt).toLocaleString()}`
      },
      permitted() {
        return salut => !this.loading && this.note.userId === this.$currentUser.id && this._isallowed(salut)
      },
      _isallowed() {
        return salut => this.$currentUser.role == "superadmin" || this.$permissions.notes[salut]
      },
      C_editForManager() {
        return this.managerView.note && this.managerView.note.id == this.DV_note.id
      }
    },
    watch: {
      note: {
        handler: function(value) {
          this.DV_note = value
        },
        deep: true
      }
    }
  }
</script>

<style scoped lang="scss">
  .notes_input {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 15px;
  }
  .note_body {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 10px;
    word-break: break-word;
    max-height: 200px;
    overflow-y: auto;
  }
  .file-icon {
    cursor: pointer;
    font-size: 15px;
    color: gray;
    margin-right: 10px;
  }
</style>
