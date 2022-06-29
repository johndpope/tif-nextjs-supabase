import { ReactElement, useState, useEffect } from 'react'
import dynamic from 'next/dynamic'
import { useRouter } from 'next/router'
import moment from 'moment'
import 'moment/locale/fr';
import { serverSideTranslations } from "next-i18next/serverSideTranslations";
import { useTranslation } from "next-i18next";

import Layout from '../components/Layout'
import NestedLayout from '../components/LayoutFrontend'
import { useAppSelector, useAppDispatch } from '../app/hooks'
import { selectEvents, fetchEvents } from '../features/events/eventsSlice'


const CountdownTimer = dynamic(
	() => import('../components/CountdownTimer'),
	{ ssr: false }
)
const DateSelection = dynamic(
	() => import('../components/DateSelection'),
	{ ssr: false }
)


// interface Event {
// 	id: number,
// 	home_team_name: string,
// 	visitor_team_name: string,
// 	home_team_score: number,
// 	visitor_team_score: number,
// 	status: string,
// 	date: Date,
// 	timestame: number,
// 	updated_at: Date
// }

export async function getServerSideProps({ locale }) {
	// Run on the server everytime the page is visited
	console.log('[getServerSideProps]', new Date());
	const current_timestamp = Math.floor(Date.now() / 1000)
	console.log('current_timestamp: ', current_timestamp - (12 * 60 * 60));
	console.log('Supabase url: ', process.env.NEXT_PUBLIC_SUPABASE_URL)
	// console.log('Supabase anon key: ', process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)
	console.log('API_FOOTBALL_KEY: ', process.env.API_FOOTBALL_KEY)
	// const { data, error } = await supabase
	// 	.from('events')
	// 	.select('*')

	// const { data, error } = await supabase
	// 	.from('events')
	// 	.select('id, home_team_name, visitor_team_name, home_team_score, visitor_team_score, status, date, timestamp, updated_at')
	// 	.gt('timestamp', (current_timestamp - 240 * 60))
	// 	// .gt('timestamp', (current_timestamp))
	// 	.order('timestamp', { ascending: true })
	// 	.limit(12)
	// console.log('error: ', error);
	// console.log('data: ', data);
	// const data = []

	return {
		props: {
			// data,
			...(await serverSideTranslations(locale, ['common', 'home']))
		}, // will be passed to the page component as props
	}
}

// const renderer = ({ hours, minutes, seconds }) => (
// 	<span>
// 	  {zeroPad(hours)}:{zeroPad(minutes)}:{zeroPad(seconds)}
// 	</span>
// );

const eventInLessThan12Hours = (timestamp: number) => {
	// console.log('timestamp: ', timestamp);
	// console.log('timestamp*1000: ', timestamp*1000)
	// console.log('Date.now(): ', Date.now())
	// console.log('diff: ', timestamp*1000 - Date.now())
	// console.log('12 * 60 * 60 * 1000: ', 12 * 60 * 60 * 1000)
	// console.log('(timestamp*1000 - Date.now()) < 12 * 60 * 60 * 1000: ', (timestamp*1000 - Date.now()) < 12 * 60 * 60 * 1000)
	return (timestamp * 1000 - Date.now() > 0 && timestamp * 1000 - Date.now() < 12 * 60 * 60 * 1000)
}




export default function HomePage({ data }) {
	const router = useRouter()
	const { t } = useTranslation(['home']);
    const events = useAppSelector(selectEvents)
	const dispatch = useAppDispatch()
	const [date, setDate] = useState<Date>();
	// const date = new Date();


	// useEffect((timestamp) => {
	// 	setCountdown(0);
	// }, [countdown]);

	useEffect(() => {
        console.log('[useEffect] fetchEvents')

        const datesInterval = {
            // date1: moment().add(-1, 'd').unix(),
			date1: moment().add(0, 'days').startOf('day').unix(),
            // date2: moment().add(+1, 'd').unix()
			date2: moment().add(0, 'days').endOf('day').unix()
        }
		console.log('datesInterval: ', datesInterval);
        // if (events && events.length < 1) {
            dispatch(fetchEvents(datesInterval));
        // }
    }, [])

	return (
		<>
			<div className="d-flex align-content-center flex-wrap" style={{ height: '600px', border: '3px solid orange' }}>
				<ul>
					<li>abc</li>
					<li>def</li>
					<li>ghi</li>
				</ul>
			</div>
		</>
	)
}

HomePage.getLayout = function getLayout(page: ReactElement) {
	return (
		<Layout>
			<NestedLayout>{page}</NestedLayout>
		</Layout>
	)
}
