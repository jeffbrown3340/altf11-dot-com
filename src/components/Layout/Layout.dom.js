import React from 'react';
import { Link } from 'react-router-dom';

const Layout = (props) => (
    <div>
        <div className='container-fluid bg-primary text-white dp-header' style={styles.header}>
            altf11
        </div>
        <div className='container-fluid'>
            {/*Renders body*/}
            {props.children}
        </div>
    </div>
);

const styles = {
    header: {
        alignItems: 'center',
        fontSize: 18,
        color: 'white',
        fontWeight: 'bold'        
    }
}

export default Layout;