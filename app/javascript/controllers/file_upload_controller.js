import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "submitButton"]

  promptFileSelection(event) {
    event.preventDefault()
    this.fileInputTarget.click()
  }

  handleFileChange() {
    if (this.fileInputTarget.files.length > 0) {
      this.submitButtonTarget.classList.remove("hidden")
    }
  }

  submitForm(event) {
    event.preventDefault()
    this.element.requestSubmit()
  }
}