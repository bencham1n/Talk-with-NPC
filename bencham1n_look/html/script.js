window.addEventListener('message', function(event) {
    var item = event.data;

    if (item.type === 'otvor_menu') {
        document.getElementById('npc-meno').textContent = item.data.meno || 'Stranger';
        document.getElementById('dialog-message').textContent = item.data.sprava || '';
        const optionsContainer = document.getElementById('dialog-options');
        document.getElementById('npc-role').innerText = item.data.rola || 'Obcan';
        document.getElementById('npc-rola-ikona').className = item.data.ikonka || 'fas fa-user-tag';
        
        optionsContainer.innerHTML = ''; // Resetni možnosti

        if (item.data.moznosti) {
            item.data.moznosti.forEach(option => {
                const button = document.createElement('button');
                button.className = 'option-button';
                button.setAttribute('data-hodnota', option.value);
                button.textContent = option.label;

                button.addEventListener('click', function () {
                    fetch(`https://${GetParentResourceName()}/akcia`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                        body: JSON.stringify({ hodnota: option.value })
                    });
                });

                optionsContainer.appendChild(button);
            });
        }

        document.getElementById('dialog-box').style.display = 'block';
        document.getElementById('dialog-options').style.display = 'flex';
    }

    else if (item.type === 'npc_response') {
        document.getElementById('dialog-message').textContent = item.data.sprava || '...';
        document.getElementById('dialog-options').style.display = 'none';
    }

    else if (item.type === 'zatvor_menu') {
        document.getElementById('dialog-box').style.display = 'none';
    }
});


document.querySelectorAll('.option-button').forEach(button => {
    button.addEventListener('click', function() {
        var hodnota = this.getAttribute('data-hodnota');
        fetch(`https://${GetParentResourceName()}/akcia`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                hodnota: hodnota
            })
        }).then(resp => resp.json()).then(data => {
            // pr�padne spracovanie odpovede
        });
        document.getElementById('dialog-box').style.display = 'none';
    });
});
