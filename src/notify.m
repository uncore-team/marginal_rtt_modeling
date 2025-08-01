function notify(recipient, subject, body)
% Send an e-mail for notification when an experiment ends.
% This script is written in Spanish.

    % test
    % recipient = 'yourmail@yourorg';
    % subject = 'email test';
    % body = 'email test';

    % Leer el archivo JSON
    json = fileread('secrets.json');
    config = jsondecode(json);

    % Configuración del servidor SMTP
    setpref('Internet', 'SMTP_Server', config.smtp_server);
    setpref('Internet', 'E_mail', config.email);
    setpref('Internet', 'SMTP_Username', config.email);
    setpref('Internet', 'SMTP_Password', config.password);
    
    % Propiedades para conexión insegura (requerido para "Aplicaciones inseguras")
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth', 'true');
    props.setProperty('mail.smtp.starttls.enable', 'true');
    props.setProperty('mail.smtp.port', config.smtp_port);
    
    try
        % Crear y enviar el mensaje
        sendmail(recipient, subject, body);
        
        disp('Correo enviado exitosamente');
    catch ME
        disp('Error al enviar el correo:');
        disp(ME.message);
        
        % Verificar si el error es por acceso no permitido
        if contains(ME.message, 'Authentication failed')
            disp(['Posibles soluciones:' newline ...
                 '1. Asegúrate de haber activado "Permitir aplicaciones menos seguras"' newline ...
                 '   en la configuración de tu cuenta de Google.' newline ...
                 '2. Verifica que el usuario y contraseña sean correctos.' newline ...
                 '3. Si usas verificación en dos pasos, necesitas una contraseña de aplicación.']);
        end
    end
end