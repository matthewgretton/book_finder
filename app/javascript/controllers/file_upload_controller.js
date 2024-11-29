import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput"]

  promptFileSelection(event) {
    this.fileInputTarget.click()
  }

  submitForm(event) {
    if (this.fileInputTarget.files.length > 0) {
      this.element.submit()
    }
  }
}