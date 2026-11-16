## 1. Summary
On 16 Nov 2026 the PRD Airflow restart failed. The 5 Airflow worker servers could not mount the finance NAS share /data/finance_bi, so the worker containers did not start and no DAG tasks ran.
Cause: the password of service account SVC2AUXCMPPCIAP was rotated around 9 Nov, but the credentials file was only updated on the master server, not on the 5 workers.

## 2. Impact
- Airflow workers down from ~08:30 until ~11:30, No DAG tasks ran in that window.
- Webserver and scheduler were up, so the UI looked partly healthy.
- Affected: pipelines reading from /data/finance_bi/INPUT.

## 3. Timeline (16 Nov, Lisbon time; server logs are CET = +1h)
- 9 Nov: credentials file updated on master eurvlii70651 after password rotation. Workers not updated.
- Morning: Hadoop restart completed.
- 08:36: Airflow restart fails: “error while creating mount source path ‘/data/finance_bi/INPUT’: no such device”.
- 09:20: Share found not mounted on master (CIFS with systemd automount).
- 09:23: Share mounted manually on master. OK.
- 09:37–09:55: restart.sh re-run 3 times, incl. Docker restart on master. Same error.
- 09:52: Test container on master reads the share fine, so the master is not the problem.
- 10:04: restart.sh reviewed. Workers are started over SSH on 5 hosts (eurvlii82377–82381). Error comes from the workers.
- 10:12: All 5 workers: share not mounted, automount stuck (“No such device”).
- 10:18: Manual mount on a worker fails with “mount error(13): Permission denied”, meaning the password is outdated.
- ~10:57: Credentials file updated on all 5 workers. Share mounted on each.
- [11:20]: restart.sh run, all workers Up, test DAG green. Service restored.

## 4. Root cause
The password rotation for SVC2AUXCMPPCIAP updated /root/.credentials/SVC2AUXCMPPCIAP on the master only. Existing mounts kept working until the next remount. During today’s restart the workers had to remount the share, authentication failed, and the systemd automount returned “no such device” to Docker, which hid the real error.

## 5. Contributing factors
- The rotation process does not list all hosts that use this credential.
- Misleading error message (“no such device” instead of an authentication error).
- Limited sudo rights (no root read of the file, no journalctl) slowed down the diagnosis.
