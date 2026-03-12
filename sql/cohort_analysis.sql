
WITH users_step4 AS (
    SELECT
        user_id,
        promo_signup_flag,
        signup_datetime,
        replace(
            replace(split_part(trim(signup_datetime), ' ', 1), '/', '-'),
            '.', '-'
        ) AS s,

        split_part(
            replace(replace(split_part(trim(signup_datetime), ' ', 1), '/', '-'), '.', '-'),
            '-', 1
        ) AS dd,
        split_part(
            replace(replace(split_part(trim(signup_datetime), ' ', 1), '/', '-'), '.', '-'),
            '-', 2
        ) AS mm,
        split_part(
            replace(replace(split_part(trim(signup_datetime), ' ', 1), '/', '-'), '.', '-'),
            '-', 3
        ) AS yy
    FROM cohort_users_raw
)

SELECT
    user_id,
    promo_signup_flag,
    signup_datetime,
    s,

    CASE
        WHEN s IS NULL OR s = '' THEN NULL

        WHEN length(yy) = 4 THEN
            to_date(yy || '-' || lpad(mm, 2, '0') || '-' || lpad(dd, 2, '0'), 'YYYY-MM-DD')::timestamp

        WHEN length(yy) = 2 THEN
            to_date(('20' || yy) || '-' || lpad(mm, 2, '0') || '-' || lpad(dd, 2, '0'), 'YYYY-MM-DD')::timestamp

        ELSE NULL
    END AS signup_ts
FROM users_step4
LIMIT 20;



WITH events_step5 AS (
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        event_datetime,

        replace(
            replace(split_part(trim(event_datetime), ' ', 1), '/', '-'),
            '.', '-'
        ) AS s,

        split_part(
            replace(replace(split_part(trim(event_datetime), ' ', 1), '/', '-'), '.', '-'),
            '-', 1
        ) AS dd,
        split_part(
            replace(replace(split_part(trim(event_datetime), ' ', 1), '/', '-'), '.', '-'),
            '-', 2
        ) AS mm,
        split_part(
            replace(replace(split_part(trim(event_datetime), ' ', 1), '/', '-'), '.', '-'),
            '-', 3
        ) AS yy
    FROM cohort_events_raw
)

SELECT
    event_id,
    user_id,
    event_type,
    revenue,
    event_datetime,
    s,

    CASE
        WHEN s IS NULL OR s = '' THEN NULL

        WHEN length(yy) = 4 THEN
            to_date(yy || '-' || lpad(mm, 2, '0') || '-' || lpad(dd, 2, '0'), 'YYYY-MM-DD')::timestamp

        WHEN length(yy) = 2 THEN
            to_date(('20' || yy) || '-' || lpad(mm, 2, '0') || '-' || lpad(dd, 2, '0'), 'YYYY-MM-DD')::timestamp

        ELSE NULL
    END AS event_ts
FROM events_step5
LIMIT 20;


WITH users_clean AS (
    SELECT
        user_id,
        promo_signup_flag,
        CASE
            WHEN signup_datetime IS NULL THEN NULL
            ELSE (
                WITH s AS (
                    SELECT replace(replace(split_part(trim(signup_datetime), ' ', 1), '/', '-'), '.', '-') AS d
                ),
                p AS (
                    SELECT
                        split_part(d, '-', 1) AS dd,
                        split_part(d, '-', 2) AS mm,
                        split_part(d, '-', 3) AS yy
                    FROM s
                )
                SELECT
                    CASE
                        WHEN length(yy) = 4 THEN to_date(yy || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        WHEN length(yy) = 2 THEN to_date(('20'||yy) || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        ELSE NULL
                    END
                FROM p
            )
        END AS signup_ts
    FROM cohort_users_raw
),

events_clean AS (
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        CASE
            WHEN event_datetime IS NULL THEN NULL
            ELSE (
                WITH s AS (
                    SELECT replace(replace(split_part(trim(event_datetime), ' ', 1), '/', '-'), '.', '-') AS d
                ),
                p AS (
                    SELECT
                        split_part(d, '-', 1) AS dd,
                        split_part(d, '-', 2) AS mm,
                        split_part(d, '-', 3) AS yy
                    FROM s
                )
                SELECT
                    CASE
                        WHEN length(yy) = 4 THEN to_date(yy || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        WHEN length(yy) = 2 THEN to_date(('20'||yy) || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        ELSE NULL
                    END
                FROM p
            )
        END AS event_ts
    FROM cohort_events_raw
),

joined_step6 AS (
    SELECT
        u.user_id,
        u.promo_signup_flag,
        e.event_id,
        e.event_type,
        e.revenue,

        date_trunc('month', u.signup_ts)::date AS cohort_month,
        date_trunc('month', e.event_ts)::date  AS activity_month,

        (
            (extract(year  from date_trunc('month', e.event_ts))::int * 12 + extract(month from date_trunc('month', e.event_ts))::int)
          - (extract(year  from date_trunc('month', u.signup_ts))::int * 12 + extract(month from date_trunc('month', u.signup_ts))::int)
        ) AS month_offset
    FROM users_clean u
    JOIN events_clean e
      ON e.user_id = u.user_id
    WHERE
        u.signup_ts IS NOT NULL      
        AND e.event_ts IS NOT NULL   
        AND e.event_type IS NOT NULL 
        AND e.event_type <> 'test_event' 
      
)

SELECT *
FROM joined_step6
ORDER BY promo_signup_flag, cohort_month, month_offset
LIMIT 1000;



WITH users_clean AS (
    SELECT
        user_id,
        promo_signup_flag,
        CASE
            WHEN signup_datetime IS NULL THEN NULL
            ELSE (
                WITH s AS (
                    SELECT replace(replace(split_part(trim(signup_datetime), ' ', 1), '/', '-'), '.', '-') AS d
                ),
                p AS (
                    SELECT
                        split_part(d, '-', 1) AS dd,
                        split_part(d, '-', 2) AS mm,
                        split_part(d, '-', 3) AS yy
                    FROM s
                )
                SELECT
                    CASE
                        WHEN length(yy) = 4 THEN to_date(yy || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        WHEN length(yy) = 2 THEN to_date(('20'||yy) || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        ELSE NULL
                    END
                FROM p
            )
        END AS signup_ts
    FROM cohort_users_raw
),

events_clean AS (
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        CASE
            WHEN event_datetime IS NULL THEN NULL
            ELSE (
                WITH s AS (
                    SELECT replace(replace(split_part(trim(event_datetime), ' ', 1), '/', '-'), '.', '-') AS d
                ),
                p AS (
                    SELECT
                        split_part(d, '-', 1) AS dd,
                        split_part(d, '-', 2) AS mm,
                        split_part(d, '-', 3) AS yy
                    FROM s
                )
                SELECT
                    CASE
                        WHEN length(yy) = 4 THEN to_date(yy || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        WHEN length(yy) = 2 THEN to_date(('20'||yy) || '-' || lpad(mm,2,'0') || '-' || lpad(dd,2,'0'), 'YYYY-MM-DD')::timestamp
                        ELSE NULL
                    END
                FROM p
            )
        END AS event_ts
    FROM cohort_events_raw
),

joined AS (
    SELECT
        u.user_id,
        u.promo_signup_flag,

        date_trunc('month', u.signup_ts)::date AS cohort_month,
        date_trunc('month', e.event_ts)::date  AS activity_month,

        (
            (extract(year  from date_trunc('month', e.event_ts))::int * 12 + extract(month from date_trunc('month', e.event_ts))::int)
          - (extract(year  from date_trunc('month', u.signup_ts))::int * 12 + extract(month from date_trunc('month', u.signup_ts))::int)
        ) AS month_offset
    FROM users_clean u
    JOIN events_clean e
      ON e.user_id = u.user_id
    WHERE
        u.signup_ts IS NOT NULL
        AND e.event_ts IS NOT NULL
        AND e.event_type IS NOT NULL
        AND e.event_type <> 'test_event'
        AND date_trunc('month', e.event_ts)::date BETWEEN DATE '2025-01-01' AND DATE '2025-06-01'
)

SELECT
    promo_signup_flag,
    cohort_month,
    month_offset,
    COUNT(DISTINCT user_id) AS users_total
FROM joined
GROUP BY 1,2,3
ORDER BY 1,2,3;





