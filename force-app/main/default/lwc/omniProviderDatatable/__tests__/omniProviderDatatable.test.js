import { createElement } from "lwc";
import OmniProviderDatatable from "c/omniProviderDatatable";

describe("c-omni-provider-datatable", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("matches snapshot", () => {
    // Arrange
    const element = createElement("c-omni-provider-datatable", {
      is: OmniProviderDatatable,
    });

    document.body.appendChild(element);

    expect(element).toMatchSnapshot();
  });
});
