import { render, screen } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import Button from './Button'

describe('Button Component', () => {
  describe('Rendering', () => {
    it('renders children text correctly', () => {
      render(<Button>Click Me</Button>)
      expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument()
    })

    it('renders with default variant (primary)', () => {
      render(<Button>Default</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('bg-green-600')
      expect(button.className).toContain('text-white')
    })

    it('renders with default size (md)', () => {
      render(<Button>Medium</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('px-4')
      expect(button.className).toContain('py-2')
    })
  })

  describe('Variants', () => {
    it('renders primary variant correctly', () => {
      render(<Button variant="primary">Primary</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('bg-green-600')
      expect(button.className).toContain('text-white')
      expect(button.className).toContain('hover:bg-green-700')
    })

    it('renders secondary variant correctly', () => {
      render(<Button variant="secondary">Secondary</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('bg-gray-100')
      expect(button.className).toContain('text-gray-700')
      expect(button.className).toContain('hover:bg-gray-200')
    })

    it('renders danger variant correctly', () => {
      render(<Button variant="danger">Danger</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('bg-red-600')
      expect(button.className).toContain('text-white')
      expect(button.className).toContain('hover:bg-red-700')
    })

    it('renders outline variant correctly', () => {
      render(<Button variant="outline">Outline</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('border')
      expect(button.className).toContain('border-gray-300')
      expect(button.className).toContain('text-gray-700')
    })
  })

  describe('Sizes', () => {
    it('renders small size correctly', () => {
      render(<Button size="sm">Small</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('px-3')
      expect(button.className).toContain('py-1.5')
      expect(button.className).toContain('text-sm')
    })

    it('renders medium size correctly', () => {
      render(<Button size="md">Medium</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('px-4')
      expect(button.className).toContain('py-2')
      expect(button.className).toContain('text-sm')
    })

    it('renders large size correctly', () => {
      render(<Button size="lg">Large</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('px-6')
      expect(button.className).toContain('py-3')
      expect(button.className).toContain('text-base')
    })
  })

  describe('Disabled State', () => {
    it('is disabled when disabled prop is true', () => {
      render(<Button disabled>Disabled</Button>)
      const button = screen.getByRole('button')
      expect(button).toBeDisabled()
      expect(button.className).toContain('disabled:opacity-50')
      expect(button.className).toContain('disabled:cursor-not-allowed')
    })

    it('is not disabled by default', () => {
      render(<Button>Enabled</Button>)
      expect(screen.getByRole('button')).not.toBeDisabled()
    })
  })

  describe('Loading State - Issue #15 Fix', () => {
    it('renders loading spinner with correct className (no backslash)', () => {
      render(<Button loading>Loading</Button>)
      const button = screen.getByRole('button')
      
      // Find the SVG spinner
      const svg = button.querySelector('svg')
      expect(svg).toBeInTheDocument()
      
      // CRITICAL: Verify className has NO backslash (fix for #15)
      expect(svg.className.baseVal).toBe('animate-spin -ml-1 mr-2 h-4 w-4')
      expect(svg.className.baseVal).not.toContain('\\')
    })

    it('disables button when loading', () => {
      render(<Button loading>Loading</Button>)
      expect(screen.getByRole('button')).toBeDisabled()
    })

    it('shows spinner icon when loading', () => {
      render(<Button loading>Loading</Button>)
      const button = screen.getByRole('button')
      const svg = button.querySelector('svg')
      
      expect(svg).toBeInTheDocument()
      expect(svg.className.baseVal).toContain('animate-spin')
    })

    it('still shows children text when loading', () => {
      render(<Button loading>Submitting...</Button>)
      expect(screen.getByRole('button', { name: /submitting/i })).toBeInTheDocument()
    })

    it('is not loading by default', () => {
      render(<Button>Not Loading</Button>)
      const button = screen.getByRole('button')
      expect(button.querySelector('svg')).not.toBeInTheDocument()
    })
  })

  describe('Custom className', () => {
    it('merges custom className with default classes', () => {
      render(<Button className="custom-class">Custom</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('custom-class')
      expect(button.className).toContain('bg-green-600') // Still has default variant
    })

    it('allows overriding styles with custom className', () => {
      render(<Button className="!bg-purple-500">Purple</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('!bg-purple-500')
    })
  })

  describe('Event Handlers', () => {
    it('calls onClick handler when clicked', () => {
      const handleClick = vi.fn()
      render(<Button onClick={handleClick}>Click</Button>)
      
      screen.getByRole('button').click()
      expect(handleClick).toHaveBeenCalledTimes(1)
    })

    it('does not call onClick when disabled', () => {
      const handleClick = vi.fn()
      render(<Button disabled onClick={handleClick}>Disabled</Button>)
      
      screen.getByRole('button').click()
      expect(handleClick).not.toHaveBeenCalled()
    })

    it('does not call onClick when loading', () => {
      const handleClick = vi.fn()
      render(<Button loading onClick={handleClick}>Loading</Button>)
      
      screen.getByRole('button').click()
      expect(handleClick).not.toHaveBeenCalled()
    })
  })

  describe('Additional Props', () => {
    it('forwards type prop to button element', () => {
      render(<Button type="submit">Submit</Button>)
      expect(screen.getByRole('button')).toHaveAttribute('type', 'submit')
    })

    it('forwards aria-label prop', () => {
      render(<Button aria-label="Close modal">X</Button>)
      expect(screen.getByLabelText('Close modal')).toBeInTheDocument()
    })

    it('forwards data attributes', () => {
      render(<Button data-testid="custom-button">Test</Button>)
      expect(screen.getByTestId('custom-button')).toBeInTheDocument()
    })
  })

  describe('Accessibility', () => {
    it('has correct role', () => {
      render(<Button>Accessible</Button>)
      expect(screen.getByRole('button')).toBeInTheDocument()
    })

    it('has focus styles', () => {
      render(<Button>Focus</Button>)
      const button = screen.getByRole('button')
      expect(button.className).toContain('focus:outline-none')
      expect(button.className).toContain('focus:ring-2')
    })

    it('indicates disabled state to screen readers', () => {
      render(<Button disabled>Disabled</Button>)
      expect(screen.getByRole('button')).toHaveAttribute('disabled')
    })

    it('indicates loading state through disabled attribute', () => {
      render(<Button loading>Loading</Button>)
      expect(screen.getByRole('button')).toBeDisabled()
    })
  })

  describe('SVG Loading Icon Structure', () => {
    it('renders SVG with correct viewBox', () => {
      render(<Button loading>Loading</Button>)
      const svg = screen.getByRole('button').querySelector('svg')
      expect(svg).toHaveAttribute('viewBox', '0 0 24 24')
      expect(svg).toHaveAttribute('fill', 'none')
    })

    it('renders circle and path elements', () => {
      render(<Button loading>Loading</Button>)
      const svg = screen.getByRole('button').querySelector('svg')
      
      const circle = svg.querySelector('circle')
      expect(circle).toBeInTheDocument()
      expect(circle).toHaveAttribute('cx', '12')
      expect(circle).toHaveAttribute('cy', '12')
      expect(circle).toHaveAttribute('r', '10')
      
      const path = svg.querySelector('path')
      expect(path).toBeInTheDocument()
      expect(path.className.baseVal).toContain('opacity-75')
    })
  })
})
