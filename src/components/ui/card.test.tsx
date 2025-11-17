import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "./card";

describe("Card Components", () => {
  describe("Card", () => {
    it("should render with default classes", () => {
      render(<Card>Card content</Card>);
      const card = screen.getByText("Card content");
      expect(card).toHaveClass("rounded-xl", "border", "bg-card");
    });

    it("should apply custom className", () => {
      render(<Card className="custom-card">Content</Card>);
      const card = screen.getByText("Content");
      expect(card).toHaveClass("custom-card");
    });
  });

  describe("CardHeader", () => {
    it("should render with default classes", () => {
      render(<CardHeader>Header content</CardHeader>);
      const header = screen.getByText("Header content");
      expect(header).toHaveClass("flex", "flex-col", "space-y-1.5", "p-6");
    });
  });

  describe("CardTitle", () => {
    it("should render with default classes", () => {
      render(<CardTitle>Title</CardTitle>);
      const title = screen.getByText("Title");
      expect(title).toHaveClass("font-semibold", "leading-none", "tracking-tight");
    });
  });

  describe("CardDescription", () => {
    it("should render with default classes", () => {
      render(<CardDescription>Description text</CardDescription>);
      const description = screen.getByText("Description text");
      expect(description).toHaveClass("text-sm", "text-muted-foreground");
    });
  });

  describe("CardContent", () => {
    it("should render with default classes", () => {
      render(<CardContent>Content text</CardContent>);
      const content = screen.getByText("Content text");
      expect(content).toHaveClass("p-6", "pt-0");
    });
  });

  describe("CardFooter", () => {
    it("should render with default classes", () => {
      render(<CardFooter>Footer content</CardFooter>);
      const footer = screen.getByText("Footer content");
      expect(footer).toHaveClass("flex", "items-center", "p-6", "pt-0");
    });
  });

  describe("Card composition", () => {
    it("should render complete card structure", () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle>Test Title</CardTitle>
            <CardDescription>Test Description</CardDescription>
          </CardHeader>
          <CardContent>Test Content</CardContent>
          <CardFooter>Test Footer</CardFooter>
        </Card>
      );

      expect(screen.getByText("Test Title")).toBeInTheDocument();
      expect(screen.getByText("Test Description")).toBeInTheDocument();
      expect(screen.getByText("Test Content")).toBeInTheDocument();
      expect(screen.getByText("Test Footer")).toBeInTheDocument();
    });
  });
});
