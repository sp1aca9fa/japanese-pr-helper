import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="spin"
export default class extends Controller {
  start(event) {
    event.preventDefault();

    const button = event.currentTarget
    button.style.width = `${button.offsetWidth}px`
    button.style.height = `${button.offsetHeight}px`
    button.innerHTML = '<i class="fa-solid fa-stroopwafel fa-spin"></i>'
    button.disabled = true

    // console.log(button);

    // div.insertAdjacentHTML("beforeend", icon);
    // event.currentTarget.remove();
    this.element.requestSubmit();
  }
}
