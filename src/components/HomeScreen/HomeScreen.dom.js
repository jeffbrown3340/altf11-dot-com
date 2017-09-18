import React from 'react';
import HomeScreenBase from './HomeScreen.base';
import { BrowserRouter, Route, Link, history } from 'react-router-dom'
import config from '../../config.base';

class HomeScreen extends HomeScreenBase {
    state = {
        loginAttempts: 0,
        loggedInRep: '',
        acctNum: ''

    }

    buttonClick() {
        console.log("Button clicked.");
    }

    render() {
        return (
            <div className='row'>
                <div style={styles.font18}>Under Construction</div>
                <div className='col col-xs-12' style={styles.loginButtonDiv}>
                    <button style={styles.loginButton} className='btn btn-danger' onClick={this.buttonClick.bind(this)}>Click Me!</button>
                </div>
                <div className='col col-xs-12' style={styles.footnoteText}>
                    jeff@jeffbrown.us<br />
                    954.683.3340<br /><br />
                </div>
            </div>
            
        );
    }

}

const styles = {
    footnoteText: {
        marginBottom: 0,
        fontSize: 18,
        color: 'white',
        fontWeight: 'bold'        
    },
    font18: {
        marginLeft: 10,
        padding: 5,
        fontSize: 18,
        color: 'white',
        fontWeight: 'bold'        
    },
    
    loginButtonDiv: { padding: 10 },
    loginButton: { margin: 5 }
}

export default HomeScreen;