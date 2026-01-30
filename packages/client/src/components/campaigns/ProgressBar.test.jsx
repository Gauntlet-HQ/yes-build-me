import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import ProgressBar from './ProgressBar'

describe('ProgressBar', () => {
  describe('Color', () => {
    it('should use green color (bg-green-500) for the progress bar', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} />
      )
      
      const progressFill = container.querySelector('div > div > div')
      expect(progressFill).toHaveClass('bg-green-500')
    })

    it('should not use blue color (regression test for issue #1)', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} />
      )
      
      const progressFill = container.querySelector('div > div > div')
      expect(progressFill).not.toHaveClass('bg-blue-500')
    })
  })

  describe('Percentage Calculation', () => {
    it('should display 50% width when halfway to goal', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} />
      )
      
      const progressFill = container.querySelector('div > div > div')
      expect(progressFill).toHaveStyle({ width: '50%' })
    })

    it('should display 100% width when goal is reached', () => {
      const { container } = render(
        <ProgressBar currentAmount={1000} goalAmount={1000} />
      )
      
      const progressFill = container.querySelector('div > div > div')
      expect(progressFill).toHaveStyle({ width: '100%' })
    })

    it('should cap at 100% width when overfunded', () => {
      const { container } = render(
        <ProgressBar currentAmount={1500} goalAmount={1000} />
      )
      
      const progressFill = container.querySelector('div > div > div')
      expect(progressFill).toHaveStyle({ width: '100%' })
    })

    it('should display 0% width when no donations', () => {
      const { container } = render(
        <ProgressBar currentAmount={0} goalAmount={1000} />
      )
      
      const progressFill = container.querySelector('div > div > div')
      expect(progressFill).toHaveStyle({ width: '0%' })
    })
  })

  describe('Text Display', () => {
    it('should show current amount and goal when showText is true', () => {
      render(<ProgressBar currentAmount={500} goalAmount={1000} showText={true} />)
      
      expect(screen.getByText('$500 raised')).toBeInTheDocument()
      expect(screen.getByText('of $1,000 goal')).toBeInTheDocument()
    })

    it('should hide text when showText is false', () => {
      render(<ProgressBar currentAmount={500} goalAmount={1000} showText={false} />)
      
      expect(screen.queryByText('$500 raised')).not.toBeInTheDocument()
      expect(screen.queryByText('of $1,000 goal')).not.toBeInTheDocument()
    })

    it('should show overfunded message when goal exceeded', () => {
      render(<ProgressBar currentAmount={1500} goalAmount={1000} showText={true} />)
      
      expect(screen.getByText(/Goal exceeded by \$500!/)).toBeInTheDocument()
    })

    it('should not show overfunded message when goal not exceeded', () => {
      render(<ProgressBar currentAmount={500} goalAmount={1000} showText={true} />)
      
      expect(screen.queryByText(/Goal exceeded/)).not.toBeInTheDocument()
    })

    it('should format large numbers with commas', () => {
      render(<ProgressBar currentAmount={123456} goalAmount={500000} showText={true} />)
      
      expect(screen.getByText('$123,456 raised')).toBeInTheDocument()
      expect(screen.getByText('of $500,000 goal')).toBeInTheDocument()
    })
  })

  describe('Size Variations', () => {
    it('should apply small size class when size is sm', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} size="sm" showText={false} />
      )
      
      // Get the inner progress bar (the colored fill div)
      const progressFill = container.querySelector('[style*="width"]')
      expect(progressFill.className).toContain('h-2')
    })

    it('should apply medium size class when size is md', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} size="md" showText={false} />
      )
      
      const progressFill = container.querySelector('[style*="width"]')
      expect(progressFill.className).toContain('h-3')
    })

    it('should apply large size class when size is lg', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} size="lg" showText={false} />
      )
      
      const progressFill = container.querySelector('[style*="width"]')
      expect(progressFill.className).toContain('h-4')
    })

    it('should default to medium size when no size specified', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} showText={false} />
      )
      
      const progressFill = container.querySelector('[style*="width"]')
      expect(progressFill.className).toContain('h-3')
    })
  })

  describe('Styling', () => {
    it('should have rounded-full class for rounded corners', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} showText={false} />
      )
      
      const progressFill = container.querySelector('[style*="width"]')
      expect(progressFill.className).toContain('rounded-full')
    })

    it('should have transition animation class', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} showText={false} />
      )
      
      const progressFill = container.querySelector('[style*="width"]')
      expect(progressFill.className).toContain('transition-all')
      expect(progressFill.className).toContain('duration-500')
    })

    it('should have gray background for the container', () => {
      const { container } = render(
        <ProgressBar currentAmount={500} goalAmount={1000} showText={false} />
      )
      
      // Find the wrapper div (parent of the progress fill)
      const progressFill = container.querySelector('[style*="width"]')
      const progressBar = progressFill.parentElement
      expect(progressBar.className).toContain('bg-gray-200')
    })
  })
})
