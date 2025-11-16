import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import React from 'react';

// Dummy component for testing purposes
const Welcome = ({ name }: { name: string }) => {
  return <h1>Hello, {name}</h1>;
};

describe('Welcome component', () => {
  it('should render the component with the correct name', () => {
    render(<Welcome name="MaszPan" />);
    expect(screen.getByText('Hello, MaszPan')).toBeInTheDocument();
  });
});

