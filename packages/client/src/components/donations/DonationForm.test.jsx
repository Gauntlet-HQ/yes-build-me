import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import DonationForm from './DonationForm'

// Mock the API client
vi.mock('../../api/client', () => ({
  default: {
    post: vi.fn(),
  },
}))

// Mock the AuthContext
const mockUseAuth = vi.fn()
vi.mock('../../context/AuthContext', () => ({
  useAuth: () => mockUseAuth(),
}))

import api from '../../api/client'

describe('DonationForm Confirmation Modal', () => {
  const mockOnSuccess = vi.fn()
  const campaignId = 'test-campaign-123'

  beforeEach(() => {
    vi.clearAllMocks()
    mockUseAuth.mockReturnValue({ user: null })
  })

  // Helper to render component
  const renderForm = (authUser = null) => {
    mockUseAuth.mockReturnValue({ user: authUser })
    return render(
      <DonationForm campaignId={campaignId} onSuccess={mockOnSuccess} />
    )
  }

  describe('AC-001: Valid amount shows confirmation modal', () => {
    it('shows confirmation modal when valid amount is entered and form is submitted', async () => {
      renderForm()
      const user = userEvent.setup()

      // Enter donor name (required for guest)
      await user.type(screen.getByLabelText(/your name/i), 'John Doe')

      // Enter amount
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')

      // Submit form
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      // Modal should appear
      expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()
      expect(screen.getByText('You are about to donate')).toBeInTheDocument()
    })

    it('shows modal when preset amount is selected', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.click(screen.getByRole('button', { name: '$25' }))
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()
      expect(screen.getByText('You are about to donate')).toBeInTheDocument()
    })
  })

  describe('AC-002: Confirm button submits donation', () => {
    it('submits donation and calls onSuccess when confirm is clicked', async () => {
      api.post.mockResolvedValueOnce({ success: true })
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '100')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      // Click confirm in modal
      await user.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        expect(api.post).toHaveBeenCalledWith(
          `/campaigns/${campaignId}/donations`,
          expect.objectContaining({
            amount: 100,
            donorName: 'John Doe',
          })
        )
      })

      await waitFor(() => {
        expect(mockOnSuccess).toHaveBeenCalled()
      })
    })

    it('closes modal after successful submission', async () => {
      api.post.mockResolvedValueOnce({ success: true })
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))
      await user.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
      })
    })
  })

  describe('AC-003: Cancel button closes modal', () => {
    it('closes modal when cancel button is clicked', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()

      await user.click(screen.getByRole('button', { name: /cancel/i }))

      expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
    })

    it('does not submit donation when cancel is clicked', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))
      await user.click(screen.getByRole('button', { name: /cancel/i }))

      expect(api.post).not.toHaveBeenCalled()
    })
  })

  describe('AC-004: Guest donor name and message shown in modal', () => {
    it('displays guest donor name in confirmation modal', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'Jane Smith')
      await user.type(screen.getByPlaceholderText(/other amount/i), '75')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Donor Name:')).toBeInTheDocument()
      expect(screen.getByText('Jane Smith')).toBeInTheDocument()
    })

    it('displays message in confirmation modal when provided', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.type(screen.getByLabelText(/message/i), 'Good luck with your campaign!')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Message:')).toBeInTheDocument()
      expect(screen.getByText(/"Good luck with your campaign!"/)).toBeInTheDocument()
    })
  })

  describe('AC-005: Anonymous donation indicator', () => {
    it('shows anonymous indicator for authenticated user who selects anonymous', async () => {
      renderForm({ id: 1, username: 'testuser' })
      const user = userEvent.setup()

      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByLabelText(/make my donation anonymous/i))
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Visibility:')).toBeInTheDocument()
      expect(screen.getByText('Anonymous donation')).toBeInTheDocument()
    })

    it('does not show anonymous indicator when not selected', async () => {
      renderForm({ id: 1, username: 'testuser' })
      const user = userEvent.setup()

      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.queryByText('Anonymous donation')).not.toBeInTheDocument()
    })
  })

  describe('AC-006: Fee breakdown shown in modal', () => {
    it('displays donation amount in fee breakdown section', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '150')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Donation Amount:')).toBeInTheDocument()
      // Amount appears multiple times (header and breakdown)
      const amounts = screen.getAllByText('$150')
      expect(amounts.length).toBeGreaterThanOrEqual(1)
    })
  })

  describe('AC-E01: Error handling - keeps modal open on API error', () => {
    it('displays error message in modal when API call fails', async () => {
      api.post.mockRejectedValueOnce(new Error('Payment failed'))
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))
      await user.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        // Error appears in both form and modal - use getAllByText
        const errors = screen.getAllByText('Payment failed')
        expect(errors.length).toBeGreaterThan(0)
      }, { timeout: 3000 })

      // Modal should still be open
      expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()
    })

    it('allows retry after error', async () => {
      api.post.mockRejectedValueOnce(new Error('Payment failed'))
      api.post.mockResolvedValueOnce({ success: true })
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))
      await user.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        // Error appears in both form and modal - use getAllByText
        const errors = screen.getAllByText('Payment failed')
        expect(errors.length).toBeGreaterThan(0)
      }, { timeout: 3000 })

      // Retry - wait for button to be enabled again
      await waitFor(() => {
        expect(screen.getByRole('button', { name: /confirm donation/i })).not.toBeDisabled()
      })
      await user.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        expect(mockOnSuccess).toHaveBeenCalled()
      }, { timeout: 3000 })
    })
  })

  describe('AC-E02: Validation prevents modal from showing', () => {
    it('shows error and prevents modal when amount is empty', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Please enter a valid donation amount')).toBeInTheDocument()
      expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
    })

    it('shows error and prevents modal when amount is zero', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '0')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Please enter a valid donation amount')).toBeInTheDocument()
      expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
    })

    it('shows error and prevents modal when guest name is empty', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Please enter your name')).toBeInTheDocument()
      expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
    })

    it('does not require guest name for authenticated users', async () => {
      renderForm({ id: 1, username: 'testuser' })
      const user = userEvent.setup()

      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.queryByText('Please enter your name')).not.toBeInTheDocument()
      expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()
    })
  })

  describe('AC-B01 & AC-B02: Modal close behaviors (via Modal component)', () => {
    it('closes modal when backdrop is clicked', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()

      // Click the backdrop (the overlay div)
      const backdrop = document.querySelector('.bg-black.bg-opacity-50')
      fireEvent.click(backdrop)

      expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
    })

    it('closes modal when Escape key is pressed', async () => {
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))

      expect(screen.getByText('Confirm Your Donation')).toBeInTheDocument()

      fireEvent.keyDown(document, { key: 'Escape' })

      expect(screen.queryByText('Confirm Your Donation')).not.toBeInTheDocument()
    })
  })

  describe('Loading states', () => {
    it('shows loading state during submission', async () => {
      let resolvePromise
      const pendingPromise = new Promise((resolve) => { resolvePromise = resolve })
      api.post.mockReturnValue(pendingPromise)
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))
      
      // Click confirm and immediately check for loading state
      fireEvent.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        // Processing appears in both main button and modal button
        const processingButtons = screen.getAllByText('Processing...')
        expect(processingButtons.length).toBeGreaterThan(0)
      }, { timeout: 1000 })

      // Cleanup - resolve the promise
      resolvePromise({ success: true })
    })

    it('disables buttons during loading', async () => {
      let resolvePromise
      const pendingPromise = new Promise((resolve) => { resolvePromise = resolve })
      api.post.mockReturnValue(pendingPromise)
      renderForm()
      const user = userEvent.setup()

      await user.type(screen.getByLabelText(/your name/i), 'John Doe')
      await user.type(screen.getByPlaceholderText(/other amount/i), '50')
      await user.click(screen.getByRole('button', { name: /donate now/i }))
      
      // Click confirm and immediately check for disabled state
      fireEvent.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        // Check that processing buttons are disabled
        const processingButtons = screen.getAllByRole('button', { name: /processing/i })
        expect(processingButtons.length).toBeGreaterThan(0)
        processingButtons.forEach(btn => expect(btn).toBeDisabled())
        expect(screen.getByRole('button', { name: /cancel/i })).toBeDisabled()
      }, { timeout: 1000 })

      // Cleanup - resolve the promise
      resolvePromise({ success: true })
    })
  })

  describe('Form reset after successful submission', () => {
    it('resets all form fields after successful donation', async () => {
      api.post.mockResolvedValueOnce({ success: true })
      renderForm()
      const user = userEvent.setup()

      const nameInput = screen.getByLabelText(/your name/i)
      const amountInput = screen.getByPlaceholderText(/other amount/i)
      const messageInput = screen.getByLabelText(/message/i)

      await user.type(nameInput, 'John Doe')
      await user.type(amountInput, '50')
      await user.type(messageInput, 'Great campaign!')
      await user.click(screen.getByRole('button', { name: /donate now/i }))
      await user.click(screen.getByRole('button', { name: /confirm donation/i }))

      await waitFor(() => {
        expect(nameInput).toHaveValue('')
        expect(amountInput).toHaveValue(null)
        expect(messageInput).toHaveValue('')
      })
    })
  })
})
