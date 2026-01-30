import { render } from '@testing-library/react'
import ProgressBar from '../components/campaigns/ProgressBar'

const { container } = render(<ProgressBar currentAmount={500} goalAmount={1000} />)
console.log('Full HTML:', container.innerHTML)
