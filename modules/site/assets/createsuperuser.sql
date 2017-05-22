--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: django
--

INSERT INTO auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) VALUES (1, 'pbkdf2_sha256$36000$smyjjE8vF4QT$zmRgQQtlZELK/xaCk10aeHTDMtOCAMyakjgWlHc8WGE=', NULL, true, 'admin', '', '', 'admin@mail.com', true, true, '2015-10-30 15:10:33.782064+00');


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: django
--

SELECT pg_catalog.setval('auth_user_id_seq', 1, true);
