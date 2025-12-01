import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    url: String
  }

  search(event) {
    const query = event.target.value
    const url = `${this.urlValue}?query=${encodeURIComponent(query)}`

    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
