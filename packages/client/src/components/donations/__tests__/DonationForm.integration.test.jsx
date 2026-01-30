import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import DonationForm from '../DonationForm'

vi.mock('../../../api/client', () => ({
  default: {
    post: vi.fn()
  }
}))

vi.mock('../../../context/AuthContext', () => ({
  useAuth: vi.fn()
}))

import api from '../../../api/client'
import { useAuth } from '../../../context/AuthContext'

describe('DonationForm Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    useAuth.mockReturnValue({ user: null })
  })

  it('shows modal when form is submitted (AC-001)', async () => {
    const user = userEvent.setup()
    render(<DonationForm campaignId="123" campaignName="Test Campaign" />)

    await user.type(screen.getByPlaceholderText('Other amount'), '25')
    await user.type(screen.getByLabelText(/your name/i), 'Test Donor')
    await user.click(screen.getByRole('button', { name: /donate now/i }))

    expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()
    expect(screen.getByText('Test Campaign')).toBeInTheDocument()
    expect(screen.getByText('$25.00')).toBeInTheDocument()
  })

  it('calls API only after modal confirm (AC-002)', async () => {
    api.post.mockResolvedValue({ success: true })
    const onSuccess = vi.fn()
    const user = userEvent.setup()

    render(<DonationForm campaignId="123" campaignName="Test Campaign" onSuccess={onSuccess} />)

    await user.type(screen.getByPlaceholderText('Other amount'), '50')
    await user.type(screen.getByLabelText(/your name/i), 'Test Donor')
    await user.click(screen.getByRole('button', { name: /donate now/i }))

    expect(api.post).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: /^confirm$/i }))

    await waitFor(() => {
      expect(api.post).toHaveBeenCalledWith('/campaigns/123/donations', {
        amount: 50,
        message: null,
        isAnonymous: false,
        donorName: 'Test Donor'
      })
    })
  })

  it('preserves form data when modal is cancelled (AC-003)', async () => {
    const user = userEvent.setup()
    render(<DonationForm campaignId="123" campaignName="Test Campaign" />)

    const amountInput = screen.getByPlaceholderText('Other amount')
    const nameInput = screen.getByLabelText(/your name/i)

    await user.type(amountInput, '75')
    await user.type(nameInput, 'Preserved Name')
    await user.click(screen.getByRole('button', { name: /donate now/i }))

    expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: /cancel/i }))

    expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
    expect(amountInput).toHaveValue(75)
    expect(nameInput).toHaveValue('Preserved Name')
  })

  it('shows logged-in user name in modal (AC-005)', async () => {
    useAuth.mockReturnValue({ user: { name: 'Logged In User' } })
    const user = userEvent.setup()

    render(<DonationForm campaignId="123" campaignName="Test Campaign" />)

    await user.type(screen.getByPlaceholderText('Other amount'), '100')
    await user.click(screen.getByRole('button', { name: /donate now/i }))

    expect(screen.getByText('Logged In User')).toBeInTheDocument()
  })

  it('handles API error after confirm (AC-E01)', async () => {
    api.post.mockRejectedValue(new Error('Payment failed'))
    const user = userEvent.setup()

    render(<DonationForm campaignId="123" campaignName="Test Campaign" />)

    await user.type(screen.getByPlaceholderText('Other amount'), '50')
    await user.type(screen.getByLabelText(/your name/i), 'Test Donor')
    await user.click(screen.getByRole('button', { name: /donate now/i }))
    await user.click(screen.getByRole('button', { name: /^confirm$/i }))

    await waitFor(() => {
      expect(screen.getByText('Payment failed')).toBeInTheDocument()
    })
  })

  it('does not show donor name field for logged-in users', async () => {
    useAuth.mockReturnValue({ user: { name: 'Test User' } })

    render(<DonationForm campaignId="123" campaignName="Test Campaign" />)

    expect(screen.queryByLabelText(/your name/i)).not.toBeInTheDocument()
  })

  it('shows anonymous checkbox for logged-in users', async () => {
    useAuth.mockReturnValue({ user: { name: 'Test User' } })

    render(<DonationForm campaignId="123" campaignName="Test Campaign" />)

    expect(screen.getByLabelText(/make my donation anonymous/i)).toBeInTheDocument()
  })
})
