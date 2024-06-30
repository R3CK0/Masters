(define (problem agentic_tool_movement)
  (:domain agent-domain)
  (:objects
    agent1 - agent
    mall home downtown - location
    banana-store - store
    bank1 - bank
    banana1 - banana
  )
  (:init
    (at agent1 home)
    (tool-at banana-store mall)
    (tool-at bank1 downtown)
    (movable banana1)
    (empty agent1)
    (= (credits) 1)
    (= (hunger) 1)
  )
  (:goal
    (and
    (= (hunger) 0)
    )
  )
)
