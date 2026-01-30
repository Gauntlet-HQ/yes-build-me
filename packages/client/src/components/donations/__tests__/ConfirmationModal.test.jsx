import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import ConfirmationModal from '../ConfirmationModal'

const defaultProps = {
  isOpen: true,
  onConfirm: vi.fn(),
  onCancel: vi.fn(),
  campaignName: 'Help Local Animal Shelter',
  amount: '50',
  donorName: 'John Doe',
  message: 'Good luck with your campaign!',
  isAnonymous: false
}

describe('ConfirmationModal', () => {
  it('renders with all donation details (AC-001)', () => {
    render(<ConfirmationModal {...defaultProps} />)

    expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()
    expect(screen.getByText('Help Local Animal Shelter')).toBeInTheDocument()
    expect(screen.getByText('$50.00')).toBeInTheDocument()
    expect(screen.getByText('John Doe')).toBeInTheDocument()
    expect(screen.getByText('Good luck with your campaign!')).toBeInTheDocument()
  })

  it('calls onConfirm when Confirm button clicked (AC-002)', () => {
    const onConfirm = vi.fn()
    render(<ConfirmationModal {...defaultProps} onConfirm={onConfirm} />)

    fireEvent.click(screen.getByRole('button', { name: /confirm/i }))
    expect(onConfirm).toHaveBeenCalledTimes(1)
  })

  it('calls onCancel when Cancel button clicked (AC-003)', () => {
    const onCancel = vi.fn()
    render(<ConfirmationModal {...defaultProps} onCancel={onCancel} />)

    fireEvent.click(screen.getByRole('button', { name: /cancel/i }))
    expect(onCancel).toHaveBeenCalledTimes(1)
  })

  it('shows Anonymous when isAnonymous is true (AC-006)', () => {
    render(<ConfirmationModal {...defaultProps} isAnonymous={true} />)

    expect(screen.getByText('Anonymous')).toBeInTheDocument()
    expect(screen.queryByText('John Doe')).not.toBeInTheDocument()
  })

  it('hides message section when message is empty (AC-B01)', () => {
    render(<ConfirmationModal {...defaultProps} message="" />)

    expect(screen.queryByText('Message:')).not.toBeInTheDocument()
  })

  it('hides message section when message is null (AC-B01)', () => {
    render(<ConfirmationModal {...defaultProps} message={null} />)

    expect(screen.queryByText('Message:')).not.toBeInTheDocument()
  })

  it('closes on Escape key press (AC-B03)', () => {
    const onCancel = vi.fn()
    render(<ConfirmationModal {...defaultProps} onCancel={onCancel} />)

    fireEvent.keyDown(document, { key: 'Escape' })
    expect(onCancel).toHaveBeenCalledTimes(1)
  })

  it('does not render when isOpen is false', () => {
    render(<ConfirmationModal {...defaultProps} isOpen={false} />)

    expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
  })

  it('displays guest user donor name (AC-004)', () => {
    render(<ConfirmationModal {...defaultProps} donorName="Guest User" />)

    expect(screen.getByText('Guest User')).toBeInTheDocument()
  })

  it('displays logged-in user name (AC-005)', () => {
    render(<ConfirmationModal {...defaultProps} donorName="Logged In User" />)

    expect(screen.getByText('Logged In User')).toBeInTheDocument()
  })
})
