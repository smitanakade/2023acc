import { createElement } from "lwc";
import QfrOmniProviderForm from "c/qfrOmniProviderForm";

describe("c-qfr-omni-provider-form", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("TODO: test case generated by CLI command, please fill in test logic", () => {
    // Arrange
    const element = createElement("c-qfr-omni-provider-form", {
      is: QfrOmniProviderForm
    });

    // Act
    document.body.appendChild(element);

    // Assert
    expect(1).toBe(1);
  });

});
