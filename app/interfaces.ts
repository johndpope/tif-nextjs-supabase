export interface Event {
    id: number,
    home_team_name: string,
    visitor_team_name: string
}

export interface Action {
    id: number,
    name: string,
    slug?: string,
    image?: string
}

export interface EventAction {
    id: number
    action_id: number
    event_id: number
    user_id: number
    username: string
    action: {
        name: string
        image: string
    }
    is_completed: boolean
    number_participants: number
    participation_threshold: number
    points: number
    inserted_at: Date
    expired_at: Date
    // updated_at: Date
}

export interface EventUserAction {
    id: number
    name?: string
    user_id: number
    event_action_id?: number
    event_action?: {
        id?: number
        name?: string
        is_completed?: boolean
    }
    inserted_at: Date
    // updated_at: Date
}