import { createElement } from "lwc";
import QfrCheckbox from "c/qfrCheckbox";

describe("c-qfr-checkbox", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("TODO: test case generated by CLI command, please fill in test logic", () => {
    // Arrange
    const element = createElement("c-qfr-checkbox", {
      is: QfrCheckbox
    });

    // Act
    document.body.appendChild(element);

    // Assert
    expect(1).toBe(1);
  });
});