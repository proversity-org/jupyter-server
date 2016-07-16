echo "c.NotebookApp.port = 3335"  >> /root/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.websocket_url = 'ws://$EB_HOSTNAME:3335'" >> /root/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '*'"  >> /root/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.allow_origin = '*'" >> /root/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.tornado_settings = { 'headers': { 'X-Frame-Options': 'ALLOW-FROM http://$EDX_HOSTNAME','Content-Security-Policy': 'frame-ancestors http://$EDX_HOSTNAME','Access-Control-Allow-Origin':  'http://$EDX_HOSTNAME','Access-Control-Allow-Headers':'origin, content-type,X-Requested-With, X-CSRF-Token','Access-Control-Expose-Headers':'*','Access-Control-Allow-Credentials':'true','Access-Control-Allow-Methods':'PUT, DELETE, POST, GET OPTIONS'}}" >> /root/.jupyter/jupyter_notebook_config.py
